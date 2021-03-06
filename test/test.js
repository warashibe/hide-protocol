const { expect } = require("chai")
const B = require("big.js")
const { waffle, ethers } = require("hardhat")
const { utils, Contract } = ethers
const { map } = require("ramda")
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
  let str, cfg, utils, viewer, addr, set, mod
  let ac, p1, p2, p3
  beforeEach(async () => {
    ac = await ethers.getSigners()
    ;[p1, p2, p3] = ac
  })

  describe("Storage", () => {
    beforeEach(async () => {
      str = await deploy("Storage")
      set = await deploy("Set")
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
    it("should keep uniq set", async () => {
      set.pushUintSet(to32("key"), 1)
      set.pushUintSet(to32("key"), 2)
      set.pushUintSet(to32("key"), 3)
      expect(arr(await set.getUintSet(to32("key")))).to.eql([1, 2, 3])
      expect((await set.getUintSetAt(to32("key"), 0)) * 1).to.eql(1)
      await set.pushUintSet(to32("key"), 4)
      expect(arr(await set.getUintSet(to32("key")))).to.eql([1, 2, 3, 4])
      await set.removeUintSet(to32("key"), 2)
      expect(arr(await set.getUintSet(to32("key")))).to.eql([1, 4, 3])
      await set.removeUintSet(to32("key"), 3)
      expect(arr(await set.getUintSet(to32("key")))).to.eql([1, 4])
      await set.removeUintSet(to32("key"), 1)
      expect(arr(await set.getUintSet(to32("key")))).to.eql([4])
      expect(arr(await set.getUintSet(to32("key"))).length).to.eql(1)
    })
  })

  describe("Config", () => {
    beforeEach(async () => {
      str = await deploy("Storage")
      set = await deploy("Set")
      addr = await deploy("Addresses", a(str))
      await str.addEditor(a(addr))
      await addr.setSet(a(set))
      utils = await deploy("Utils")
      addr.setUtils(a(utils))
      viewer = await deploy("Viewer", a(addr))
      addr.setViewer(a(viewer))
      mod = await deploy("Modifiers", a(addr))
      await addr.setModifiers(a(mod))
      cfg = await deploy("Config", a(addr))
      await str.addEditor(a(cfg))
      await set.addEditor(a(cfg))
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
    wpvp,
    token,
    agt,
    wp,
    gov,
    withdraw,
    vp,
    jpyc,
    doggod,
    market,
    events,
    nft,
    p,
    cfg,
    mcfg,
    fct,
    dex,
    topics,
    str,
    aggr,
    utils,
    viewer,
    addr,
    set,
    mod
  let ac, owner, collector, p1, p2, p3
  const checkEqualty = async pairs => {
    let total = B(from18(await viewer.getAvailable(0)))
    for (const v of pairs) {
      const pair = await viewer.getPair(0, v)
      const pToken = new Contract(pair, _IERC20.abi, owner)
      total = total
        .add(from18(await pToken.totalSupply()))
        .add(from18(await viewer.claimable(pair)))
    }
    expect(B(from18(await jpyc.balanceOf(a(withdraw)))).toFixed(0)).to.equal(
      total.toFixed(0)
    )
  }

  beforeEach(async () => {
    ac = await ethers.getSigners()
    ;[owner, collector, p1, p2, p3] = ac

    // WP
    wp = await deploy("Token", "Warashibe Point", "WP", to18(100000000))

    // JPYC
    jpyc = await deploy("Token", "JPYC", "JPYC", to18(100000000))

    // DOGGOD
    doggod = await deploy("Token", "DOGGOD", "DOGGOD", to18(100000000))

    // WPVP
    wpvp = await deploy("WPVP")

    // Storage
    str = await deploy("Storage")

    // Set
    set = await deploy("Set")

    // Addresses
    addr = await deploy("Addresses", a(str))
    await str.addEditor(a(addr))
    await addr.setSet(a(set))

    // Events
    events = await deploy("Events", a(addr))
    await addr.setEvents(a(events))

    // Utils
    utils = await deploy("Utils")
    await addr.setUtils(a(utils))

    // Viewer
    viewer = await deploy("Viewer", a(addr))
    await addr.setViewer(a(viewer))

    // Mod
    mod = await deploy("Modifiers", a(addr))
    await addr.setModifiers(a(mod))

    // Aggr
    aggr = await deploy("Aggregator", a(addr))

    // Config
    cfg = await deploy("Config", a(addr))
    await addr.setConfig(a(cfg))
    await str.addEditor(a(cfg))
    await set.addEditor(a(cfg))
    await cfg.setFreigeldRate(63419584, 1000000000000000)

    // Config Market
    mcfg = await deploy("ConfigMarket", a(addr))
    await addr.setConfigMarket(a(mcfg))
    await str.addEditor(a(mcfg))
    await set.addEditor(a(mcfg))
    await mcfg.setCreatorPercentage(8000)
    await mcfg.setBurnLimits(a(jpyc), to18(1000))
    await mcfg.setDilutionRate(63419584, 1000000000000000)

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

    // Withdraw
    withdraw = await deploy("Withdraw", a(addr))
    await addr.setWithdraw(a(withdraw))

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
    await events.addEmitter(a(gov))

    // Factory
    fct = await deploy("Factory", a(addr))
    await addr.setFactory(a(fct))
    await col.addAgent(a(fct))
    await events.addEmitter(a(fct))

    // Topics
    topics = await deploy(
      "NFT",
      "Hide Topics",
      "HIDETOPICS",
      "https://hide.ac/api/topics/"
    )
    await addr.setTopics(a(topics))
    await topics.addMinter(a(fct))
    await fct.createFreeTopic("FREE", "free", "create")

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
    await events.addEmitter(a(market))

    // DEX
    dex = await deploy("DEX", a(addr))
    await addr.setDEX(a(dex))
    await col.addAgent(a(dex))
    await events.addEmitter(a(dex))

    // VP
    vp = await deploy("JPYCVP", a(wpvp), a(addr))
    await wpvp.bulkRecordWP(
      [a(p1), a(p2), a(p3)],
      [a(p1), a(p2), a(p3)],
      [to18("100"), to18("100"), to18("100")],
      [to18("100"), to18("100"), to18("100")]
    )
    await wpvp.setTotalWP(to18("1000"))
    await gov.addPool(a(vp), "JPYC")
    p = await viewer.getPool("JPYC")

    // Create Topics
    await fct.createTopic("TOPIC1", "topic1", "create")
    await fct.createTopic("TOPIC2", "topic2", "create")

    // Create Items
    await market.connect(p3).createItem("item", [1], "create")
    await market.connect(p3).createItem("item2", [3], "create")
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
    expect(await vp.getVP(a(p1))).to.equal(to18(100))
    expect(await vp.getVP(a(p2))).to.equal(to18(100))
    expect(await vp.getVP(a(p3))).to.equal(to18(100))

    // updateItem topics
    await market.connect(p3).updateItem(a(nft), 2, [2], "update")

    // set poll
    await jpyc.approve(a(gov), UINT_MAX)
    await gov.setPoll(p, a(jpyc), to18(1000), 30, [])

    // vote for topic
    const mintable0 = await viewer.getMintable(0, to18(10), 2)
    await gov.connect(p1).vote(0, to18(10), 2, "vote")

    // get pair token
    const pair2 = await viewer.getPair(0, 2)
    const pToken2 = new Contract(pair2, _IERC20.abi, owner)
    expect(await pToken2.balanceOf(a(p1))).to.equal(to18(10))
    expect(await pToken2.balanceOf(a(p1))).to.equal(mintable0.mintable)

    // burn for item
    await pToken2.connect(p1).approve(a(market), UINT_MAX)
    await market.connect(p1).burnFor(a(nft), 2, pair2, to18(5), "ref")
    expect(await jpyc.balanceOf(a(p1))).to.equal(to18(101))
    expect(await jpyc.balanceOf(a(p3))).to.equal(to18(104))
    expect(await jpyc.balanceOf(a(withdraw))).to.equal(to18(995))

    // vote for topic with shareholders
    const mintable = await viewer.getMintable(0, to18(30), 2)
    await gov.connect(p3).vote(0, to18(30), 2, "vote")
    expect(await pToken2.balanceOf(a(p3))).to.equal(
      B(mintable.mintable).minus(1).toFixed(0)
    )

    const share = (await viewer.balanceOf(a(pToken2), a(p1))).toString() * 1
    const minus = B((await viewer.share_sqrt(pair2, a(p1))).toString())
      .mul(B((await viewer.dilution_numerator()).toString()))
      .div(B((await viewer.dilution_denominator()).toString()))
    const convertible = (
      await viewer.getConvertibleAmount(a(pToken2), share, a(p1))
    ).toString()
    const balance = (await pToken2.balanceOf(a(p1))).toString()

    await dex
      .connect(p1)
      .convert(a(pToken2), B(share).minus(minus).toFixed(0), "convert")
    const balance2 = (await pToken2.balanceOf(a(p1))).toString()
    expect(
      B(balance2)
        .minus(balance * 1)
        .toNumber()
    ).to.be.gt(0)
    // close poll => claim period
    await gov.closePoll(0)
    await isErr(gov.connect(p3).vote(0, to18(30), 2), "vote")

    // check remaining amounts
    await checkEqualty([2])
  })

  it("should upgrade contracts", async () => {
    // Addresses
    addr = await deploy("Addresses", a(str))
    await str.addEditor(a(addr))
    await addr.setSet(a(set))
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
    await events.addEmitter(a(gov))

    // Factory
    fct = await deploy("Factory", a(addr))
    await addr.setFactory(a(fct))
    await col.addAgent(a(fct))
    await topics.addMinter(a(fct))
    await events.addEmitter(a(fct))

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
    await events.addEmitter(a(gov))

    await fct.createTopic("TOPIC3", "topic3", "create")
  })

  it("should add/remove fund to poll", async () => {
    // set poll
    await jpyc.approve(a(gov), UINT_MAX)
    await gov.setPoll(p, a(jpyc), to18(10), 30, [])
    let poll = await viewer.polls(0)
    expect(from18(B(poll.amount).sub(poll.minted).toFixed()) * 1).to.equal(10)

    // add fund
    await jpyc.approve(a(withdraw), UINT_MAX)
    await withdraw.addFund(0, to18(10))
    poll = await viewer.polls(0)
    expect(from18(B(poll.amount).sub(poll.minted).toFixed()) * 1).to.equal(20)
    expect(from18(await jpyc.balanceOf(a(withdraw))) * 1).to.equal(20)
    await gov.connect(p1).vote(0, to18(30), 2, "vote")
    poll = await viewer.polls(0)
    expect(from18(B(poll.amount).sub(poll.minted).toFixed()) * 1).to.equal(19.4)

    // remove fund
    await isErr(withdraw.removeFund(0, to18(20)))
    await isErr(withdraw.connect(p2).removeFund(0, to18(19.4)))
    await withdraw.removeFund(0, to18(19.4))
    await isErr(gov.connect(p1).vote(0, to18(30), 2), "vote")
    poll = await viewer.polls(0)
    expect(from18(B(poll.amount).sub(poll.minted).toFixed()) * 1).to.equal(0)
  })

  it("should hold correct remaining fund", async () => {
    // set poll
    await jpyc.approve(a(gov), UINT_MAX)
    await gov.setPoll(p, a(jpyc), to18(1000), 30, [])

    // vote for topic
    await gov.connect(p1).vote(0, to18(100), 2, "vote")

    // update item topic
    await market.connect(p3).updateItem(a(nft), 2, [2], "update")

    // get pair token 2
    const pair2 = await viewer.getPair(0, 2)
    const pToken2 = new Contract(pair2, _IERC20.abi, owner)

    await checkEqualty([2])

    // burn for item
    await pToken2.connect(p1).approve(a(market), UINT_MAX)
    await market.connect(p1).burnFor(a(nft), 2, pair2, to18(5), "ref")
    expect(await jpyc.balanceOf(a(p1))).to.equal(to18(101))
    expect(await jpyc.balanceOf(a(p3))).to.equal(to18(104))
    expect(await jpyc.balanceOf(a(withdraw))).to.equal(to18(995))

    await checkEqualty([2])

    // vote for topic with shareholders
    const mintable = await viewer.getMintable(0, to18(30), 2)
    await gov.connect(p3).vote(0, to18(30), 2, "vote")
    expect(await pToken2.balanceOf(a(p3))).to.equal(
      B(mintable.mintable).minus(1).toFixed(0)
    )

    await checkEqualty([2])

    const share = (await viewer.balanceOf(a(pToken2), a(p1))).toString() * 1
    const minus = B((await viewer.share_sqrt(pair2, a(p1))).toString())
      .mul(B((await viewer.dilution_numerator()).toString()))
      .div(B((await viewer.dilution_denominator()).toString()))
    const convertible = (
      await viewer.getConvertibleAmount(a(pToken2), share, a(p1))
    ).toString()
    const balance = (await pToken2.balanceOf(a(p1))).toString()
    await dex
      .connect(p1)
      .convert(a(pToken2), B(share).minus(minus).toFixed(0), "convert")
    const balance2 = (await pToken2.balanceOf(a(p1))).toString()
    expect(
      B(balance2)
        .minus(balance * 1)
        .toNumber()
    ).to.be.gt(0)

    await checkEqualty([2])

    // close poll => claim period
    await gov.closePoll(0)
    await isErr(gov.connect(p3).vote(0, to18(30), 2, "vote"))

    await checkEqualty([2])

    // burn for item
    await pToken2.connect(p1).approve(a(market), UINT_MAX)
    await market.connect(p1).burnFor(a(nft), 2, pair2, to18(5), "ref")
    expect(await jpyc.balanceOf(a(p1))).to.equal(to18(102))
    expect(await jpyc.balanceOf(a(p3))).to.equal(to18(108))
    expect(await jpyc.balanceOf(a(withdraw))).to.equal(to18(990))

    await checkEqualty([1, 2])
  })

  it("should reflext VP", async () => {
    // set poll
    await jpyc.approve(a(gov), UINT_MAX)
    await gov.setPoll(p, a(jpyc), to18(1000), 30, [])

    // vote for topic
    expect(from18(await vp.getVP(a(p1))) * 1).to.equal(100)
    expect(from18(await vp.getTotalVP()) * 1).to.equal(1000)
    await gov.connect(p1).vote(0, to18(10), 2, "vote")
    expect(from18(await vp.getVP(a(p1))) * 1).to.equal(90)
    expect(from18(await vp.getTotalVP()) * 1).to.equal(990)
  })

  it("should record user/item pairs", async () => {
    // set poll
    await jpyc.approve(a(gov), UINT_MAX)
    await gov.setPoll(p, a(jpyc), to18(1000), 30, [])

    // vote for topic
    await gov.connect(p1).vote(0, to18(10), 2, "vote")
    await gov.connect(p1).vote(0, to18(10), 1, "vote")
    await gov.connect(p1).vote(0, to18(10), 3, "vote")

    // update item topic
    await market.connect(p3).updateItem(a(nft), 2, [1, 2, 3], "update")

    // get pair token 2
    const pair2 = await viewer.getPair(0, 2)
    const pair1 = await viewer.getPair(0, 1)
    const pair3 = await viewer.getPair(0, 3)

    // burn for item
    const pToken2 = new Contract(pair2, _IERC20.abi, owner)
    const pToken3 = new Contract(pair3, _IERC20.abi, owner)
    await pToken2.connect(p1).approve(a(market), UINT_MAX)
    await pToken3.connect(p1).approve(a(market), UINT_MAX)
    await market.connect(p1).burnFor(a(nft), 2, pair2, to18(5), "ref")
    await market.connect(p1).burnFor(a(nft), 2, pair3, to18(5), "ref")
    expect(await viewer.user_pairs(a(p1))).to.eql([pair2, pair1, pair3])
    expect(await viewer.item_pairs(a(nft), 2)).to.eql([pair2, pair3])
  })

  it.only("should aggregate", async () => {
    // set poll
    await jpyc.approve(a(gov), UINT_MAX)
    await gov.setPoll(p, a(jpyc), to18(1000), 30, [])

    // vote for topic
    await gov.connect(p1).vote(0, to18(10), 2, "vote")
    await gov.connect(p1).vote(0, to18(10), 1, "vote")
    await gov.connect(p1).vote(0, to18(10), 3, "vote")

    // update item topic
    await market.connect(p3).updateItem(a(nft), 2, [1, 2, 3], "update")

    // get pair token 2
    const pair2 = await viewer.getPair(0, 2)
    const pair1 = await viewer.getPair(0, 1)
    const pair3 = await viewer.getPair(0, 3)

    // burn for item
    const pToken2 = new Contract(pair2, _IERC20.abi, owner)
    const pToken3 = new Contract(pair3, _IERC20.abi, owner)
    await pToken2.connect(p1).approve(a(market), UINT_MAX)
    await pToken3.connect(p1).approve(a(market), UINT_MAX)
    await market.connect(p1).burnFor(a(nft), 2, pair2, to18(5), "ref")
    await market.connect(p1).burnFor(a(nft), 2, pair3, to18(5), "ref")
    expect((await aggr.infoTopic("TOPIC1")).topic.toString() * 1).to.equal(2)
    expect(from18((await aggr.infoVote(0, to18(5), 2, a(p1))).balances[1]) * 1)
      .to.be.gt(7)
      .lt(8)
    expect(
      (await aggr.infoUser(a(p1), [a(jpyc)])).topics[0].toString() * 1
    ).to.equal(2)
    console.log(await aggr.infoItem(a(nft), 2, a(p1), [a(jpyc), a(doggod)]))
    expect(
      (await aggr.infoItem(a(nft), 2, a(p1), [a(jpyc), a(doggod)]))
        .votable_pairs.length
    ).to.equal(6)
    const tokens = (await aggr.infoUser(a(p1), [a(jpyc), a(doggod)])).pairs
    expect((await aggr.infoDEX(tokens, a(p1))).per[1].toString() * 1).to.equal(
      0
    )
    expect(
      (await aggr.infoBudgets([pair1, pair2, pair3])).tokens.length
    ).to.equal(6)
  })
})
