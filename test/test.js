const { expect } = require("chai")
const B = require("big.js")
const { waffle, ethers } = require("hardhat")
const { utils, Contract } = ethers
const _IERC20 = require("@openzeppelin/contracts/build/contracts/IERC20.json")
const {
  arr,
  isErr,
  to18,
  to32,
  from18,
  UINT_MAX,
  deploy,
  a,
} = require("./utils")

describe("Unit", () => {
  let str, cfg, utils, viewer, addr
  let ac, p1, p2, p3
  beforeEach(async () => {
    ac = await ethers.getSigners()
    ;[p1, p2, p3] = ac
  })

  describe("Storage", () => {
    beforeEach(async () => {
      str = await deploy("Storage")
    })
    it("should allow only EDITOR", async () => {
      await isErr(str.connect(p2).setUint(to32("key"), 3))
      await str.addEditor(a(p2))
      await str.connect(p2).setUint(to32("key"), 3)
      expect(await str.getUint(to32("key"))).to.equal(3)
      await str.removeEditor(a(p2))
      await isErr(str.connect(p2).setUint(to32("key"), 5))
      expect(await str.getUint(to32("key"))).to.equal(3)
    })
    it("should set UintArray", async () => {
      str.setUintArray(to32("key"), [1, 2, 3])
      expect(arr(await str.getUintArray(to32("key")))).to.eql([1, 2, 3])
    })
  })

  describe("Config", () => {
    beforeEach(async () => {
      str = await deploy("Storage")
      addr = await deploy("Addresses", a(str))
      await str.addEditor(a(addr))
      utils = await deploy("Utils")
      addr.setUtils(a(utils))
      viewer = await deploy("Viewer", a(addr))
      addr.setViewer(a(viewer))
      cfg = await deploy("Config", a(addr))
      await str.addEditor(a(cfg))
      addr.setConfig(a(cfg))
    })
    it("should persist with Storage", async () => {
      await addr.setDEX(a(p1))
      expect(await addr.dex()).to.equal(a(p1))
    })
    it("should allow only Protocol contracts", async () => {
      await isErr(cfg.setMinted(1, a(p1), 1))
      await addr.setGovernance(a(p1))
      await cfg.setMinted(1, a(p1), 1)
      expect(await viewer.minted(1, a(p1))).to.equal(1)
    })
  })
})

describe("Integration", () => {
  let col,
    token,
    agt,
    wp,
    gov,
    pool,
    jpyc,
    market,
    nft,
    p,
    cfg,
    fct,
    dex,
    topics,
    str,
    utils,
    viewer,
    addr
  let ac, owner, collector, p1, p2, p3

  beforeEach(async () => {
    ac = await ethers.getSigners()
    ;[owner, collector, p1, p2, p3] = ac

    // WP
    wp = await deploy("Token", "Warashibe Point", "WP", to18(100000000))

    // JPYC
    jpyc = await deploy("Token", "JPYC", "JPYC", to18(100000000))

    // Storage
    str = await deploy("Storage")

    // Addresses
    addr = await deploy("Addresses", a(str))
    await str.addEditor(a(addr))

    // Utils
    utils = await deploy("Utils")
    await addr.setUtils(a(utils))

    // Viewer
    viewer = await deploy("Viewer", a(addr))
    await addr.setViewer(a(viewer))

    // Config
    cfg = await deploy("Config", a(addr))
    await addr.setConfig(a(cfg))
    await str.addEditor(a(cfg))
    await cfg.setCreatorPercentage(8000)
    await cfg.setFreigeldRate(63419584, 1000000000000000)

    // Collector
    col = await deploy(
      "Collector",
      [a(wp), a(jpyc)],
      [to18(1), to18(1)],
      a(collector)
    )
    await addr.setCollector(a(col))
    agt = await deploy("Agent", a(col))
    await col.addAgent(a(agt))

    // Transfer
    await wp.transfer(a(p1), to18(100))
    await wp.transfer(a(p2), to18(100))
    await wp.transfer(a(p3), to18(100))

    await jpyc.transfer(a(p1), to18(100))
    await jpyc.transfer(a(p2), to18(100))
    await jpyc.transfer(a(p3), to18(100))

    await wp.approve(a(col), UINT_MAX)
    await wp.connect(p1).approve(a(col), UINT_MAX)
    await wp.connect(p2).approve(a(col), UINT_MAX)
    await wp.connect(p3).approve(a(col), UINT_MAX)

    // Governance
    gov = await deploy("Governance", a(addr))
    await addr.setGovernance(a(gov))
    await col.addAgent(a(gov))

    // Factory
    fct = await deploy("Factory", a(addr))
    await addr.setFactory(a(fct))
    await col.addAgent(a(fct))

    // Topics
    topics = await deploy(
      "NFT",
      "Hide Topics",
      "HIDETOPICS",
      "https://hide.ac/api/topics/"
    )
    await addr.setTopics(a(topics))
    await topics.addMinter(a(fct))
    await fct.createFreeTopic("FREE", "free")

    // NFT
    nft = await deploy(
      "NFT",
      "Hide Articles",
      "HIDEARTICLES",
      "https://hide.ac/api/items/"
    )

    // Market
    market = await deploy("Market", a(nft), a(addr))
    await nft.addMinter(a(market))
    await addr.setMarket(a(market))
    await col.addAgent(a(market))

    // DEX
    dex = await deploy("DEX", a(addr))
    await addr.setDEX(a(dex))
    await col.addAgent(a(dex))

    // Pool
    pool = await deploy("Pool", a(jpyc), a(addr))

    await gov.addPool(a(pool), "JPYC")
    p = await viewer.getPool("JPYC")
    await jpyc.transfer(a(pool), to18(10000))

    // Create Topics
    await fct.createTopic("TOPIC1", "topic1")
    await fct.createTopic("TOPIC2", "topic2")

    // Create Items
    await market.connect(p3).createItem("item", [1])
    await market.connect(p3).createItem("item2", [3])
  })

  it("should deploy contracts", async () => {})

  it("should collect fees", async () => {
    expect(await wp.balanceOf(a(collector))).to.equal(to18(5))
    expect(await wp.balanceOf(a(p2))).to.equal(to18(100))
    await agt.connect(p2).test()
    expect(await wp.balanceOf(a(collector))).to.equal(to18(6))
    expect(await wp.balanceOf(a(p2))).to.equal(to18(99))
  })

  it("should go through the whole flow", async () => {
    // check setup
    expect(await pool.getVP(a(p1))).to.equal(to18(100))
    expect(await pool.getVP(a(p2))).to.equal(to18(100))
    expect(await pool.getVP(a(p3))).to.equal(to18(100))
    expect(await pool.available()).to.equal(to18(10000))

    // updateItem topics
    await market.connect(p3).updateItem(a(nft), 2, [2])
    // set poll
    await gov.setPoll(p, to18(1000), 30, [])

    // vote for topic
    await gov.connect(p1).vote(0, to18(10), 2)

    // get pair token
    const pair2 = await viewer.getPair(p, 2)
    const pToken2 = new Contract(pair2, _IERC20.abi, owner)
    expect(await pToken2.balanceOf(a(p1))).to.equal(to18(10))

    // burn for item
    await pToken2.connect(p1).approve(a(market), UINT_MAX)
    await market.connect(p1).burnFor(a(nft), 2, p, 2, to18(5))
    expect(await jpyc.balanceOf(a(p1))).to.equal(to18(101))
    expect(await jpyc.balanceOf(a(p3))).to.equal(to18(104))
    expect(await jpyc.balanceOf(p)).to.equal(to18(9995))

    // vote for topic with shareholders
    const mintable = await viewer.getMintable(0, to18(30), 2)
    await gov.connect(p3).vote(0, to18(30), 2)
    expect(await pToken2.balanceOf(a(p3))).to.equal(mintable.mintable)

    const share = (await viewer.share_sqrt(a(pToken2), a(p1))).toString() * 1
    const convertible = (
      await viewer.getConvertibleAmount(a(pToken2), share, a(p1))
    ).toString()
    const balance = (await pToken2.balanceOf(a(p1))).toString()
    await dex.connect(p1).convert(a(pToken2), share)
    expect(
      B((await pToken2.balanceOf(a(p1))).toString())
        .minus(balance * 1)
        .minus(convertible * 1)
        .toNumber()
    ).to.be.gt(0)

    // close poll => claim period
    await gov.closePoll(0)
    await isErr(gov.connect(p3).vote(0, to18(30), 2))
    expect(await viewer.getClaimable(0, a(p1))).to.equal(to18(240))
    expect(await viewer.getClaimable(0, a(p3))).to.equal(to18(720))
    await gov.connect(p1).mint(0, to18(240), 3)
    const pair3 = await viewer.getPair(p, 3)
    const pToken3 = new Contract(pair3, _IERC20.abi, owner)
    expect(await viewer.getClaimable(0, a(p1))).to.equal(to18(0))
    expect(await pToken3.balanceOf(a(p1))).to.equal(to18(240))

    // close claim => free topic gets the rest
    await gov.closeClaim(0)
    await isErr(gov.connect(p1).mint(0, to18(240), 3))
    const pair1 = await viewer.getPair(p, 1)
    const pToken1 = new Contract(pair1, _IERC20.abi, owner)
    expect(await viewer.claimable(a(pToken1))).to.equal(to18(720))
  })

  it("should upgrade contracts", async () => {
    // Addresses
    addr = await deploy("Addresses", a(str))
    await str.addEditor(a(addr))
    await addr.setCollector(a(col))

    // Config
    cfg = await deploy("Config", a(addr))
    await addr.setConfig(a(cfg))
    await str.addEditor(a(cfg))

    // Utils
    utils = await deploy("Utils")
    await addr.setUtils(a(utils))

    // Viewer
    viewer = await deploy("Viewer", a(addr))
    await addr.setViewer(a(viewer))

    // Governance
    gov = await deploy("Governance", a(addr))
    await addr.setGovernance(a(gov))
    await col.addAgent(a(gov))

    // Factory
    fct = await deploy("Factory", a(addr))
    await addr.setFactory(a(fct))
    await col.addAgent(a(fct))
    await topics.addMinter(a(fct))

    // NFT
    nft = await deploy(
      "NFT",
      "Hide Articles",
      "HIDEARTICLES",
      "https://hide.ac/api/items/"
    )

    // Market
    market = await deploy("Market", a(nft), a(addr))
    await nft.addMinter(a(market))
    await addr.setMarket(a(market))
    await col.addAgent(a(market))

    await fct.createTopic("TOPIC3", "topic3")
  })
})
