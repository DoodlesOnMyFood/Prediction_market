let Dummy = artifacts.require('DummyBackend')

module.exports = (deployer) => {
    deployer.deploy(Dummy)
}
