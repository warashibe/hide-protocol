const B = require("big.js")
const { expect } = require("chai")
const { ethers } = require("hardhat")
const { utils } = ethers

module.exports.to18 = n => utils.parseEther(B(n).toFixed(0))

module.exports.from18 = utils.formatEther

module.exports.to32 = utils.formatBytes32String

module.exports.from32 = utils.parseBytes32String

module.exports.UINT_MAX = B(2).pow(256).sub(1).toFixed(0)

module.exports.arr = _arr => eval(`[${_arr.toString()}]`)

module.exports.deploy = async (contract, ...args) =>
  (await ethers.getContractFactory(contract)).deploy(...args)

module.exports.a = obj => obj.address

module.exports.isErr = async fn => {
  let err = false
  try {
    await fn
  } catch (e) {
    err = true
  }
  expect(err).to.be.true
}
