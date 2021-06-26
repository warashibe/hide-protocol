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
  let str, cfg
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
      cfg = await deploy("Config", a(str))
      await str.addEditor(a(cfg))
    })
    it("should persist with Storage", async () => {
      await cfg.setDEX(a(p1))
      expect(await cfg.dex()).to.equal(a(p1))
    })
    it("shoul allow only Protocol contracts", async () => {
      await isErr(cfg.setMinted(1, a(p1), 1))
      await cfg.setGovernance(a(p1))
      await cfg.setMinted(1, a(p1), 1)
      expect(await cfg.minted(1, a(p1))).to.equal(1)
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
    str
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

    // Config
    cfg = await deploy("Config", a(str))
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
    await cfg.setCollector(a(col))
    agt = await deploy("Agent", a(col))
    await col.addAgent(a(agt))

    // Governance
    gov = await deploy("Governance", a(cfg))
    await cfg.setGovernance(a(gov))
    await col.addAgent(a(gov))

    // Factory
    fct = await deploy("Factory", a(gov), a(cfg))
    await cfg.setFactory(a(fct))
    await col.addAgent(a(fct))

    // DEX
    dex = await deploy("DEX", a(cfg))
    await cfg.setDEX(a(dex))
    await col.addAgent(a(dex))

    // NFT
    nft = await deploy(
      "NFT",
      "Hide NFT",
      "HIDENFT",
      "https://hide.ac/api/items/"
    )

    // Topics
    topics = await deploy(
      "NFT",
      "Hide Topics",
      "HIDETOPICS",
      "https://hide.ac/api/topics/"
    )
    await cfg.setTopics(a(topics))
    await topics.addMinter(a(fct))
    await fct.createFreeTopic("FREE", "free")

    // Market
    market = await deploy("Market", a(nft), a(cfg))
    await nft.addMinter(a(market))
    await cfg.setMarket(a(market))
    await col.addAgent(a(market))

    // Pool
    pool = await deploy("Pool", a(jpyc), a(market))
    await gov.addPool(a(pool), "JPYC")
    p = await cfg.getPool("JPYC")

    // Transfer
    await jpyc.transfer(a(pool), to18(10000))

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

    // Create Topics
    await fct.createTopic("TOPIC1", "topic1")
    await fct.createTopic("TOPIC2", "topic2")

    // Create Items
    await market.connect(p3).createItem("item", [1])
    await market.connect(p3).createItem("item2", [2])
  })

  it("Whote flow", async () => {
    // check setup
    expect(await pool.getVP(a(p1))).to.equal(to18(100))
    expect(await pool.getVP(a(p2))).to.equal(to18(100))
    expect(await pool.getVP(a(p3))).to.equal(to18(100))
    expect(await pool.available()).to.equal(to18(10000))

    // set poll
    await gov.setPoll(p, to18(1000), 30, [])

    // vote for topic
    await gov.connect(p1).vote(0, to18(10), 2)

    // get pair token
    const pair2 = await cfg.getPair(p, 2)
    const pToken2 = new Contract(pair2, _IERC20.abi, owner)
    expect(await pToken2.balanceOf(a(p1))).to.equal(to18(10))

    // burn for item
    await pToken2.connect(p1).approve(a(market), UINT_MAX)
    await market.connect(p1).burnFor(a(nft), 2, p, 2, to18(5))
    expect(await jpyc.balanceOf(a(p1))).to.equal(to18(101))
    expect(await jpyc.balanceOf(a(p3))).to.equal(to18(104))
    expect(await jpyc.balanceOf(p)).to.equal(to18(9995))

    // vote for topic with shareholders
    const mintable = await gov.getMintable(0, to18(30), 2)
    await gov.connect(p3).vote(0, to18(30), 2)
    expect(await pToken2.balanceOf(a(p3))).to.equal(mintable.mintable)

    const share = (await cfg.share_sqrt(a(pToken2), a(p1))).toString() * 1
    const convertible = (
      await dex.getConvertibleAmount(a(pToken2), share, a(p1))
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
    expect(await cfg.getClaimable(0, a(p1))).to.equal(to18(240))
    expect(await cfg.getClaimable(0, a(p3))).to.equal(to18(720))
    await gov.connect(p1).mint(0, to18(240), 3)
    const pair3 = await cfg.getPair(p, 3)
    const pToken3 = new Contract(pair3, _IERC20.abi, owner)
    expect(await cfg.getClaimable(0, a(p1))).to.equal(to18(0))
    expect(await pToken3.balanceOf(a(p1))).to.equal(to18(240))

    // close claim => free topic gets the rest
    await gov.closeClaim(0)
    await isErr(gov.connect(p1).mint(0, to18(240), 3))
    const pair1 = await cfg.getPair(p, 1)
    const pToken1 = new Contract(pair1, _IERC20.abi, owner)
    expect(await cfg.claimable(a(pToken1))).to.equal(to18(720))
  })
})
