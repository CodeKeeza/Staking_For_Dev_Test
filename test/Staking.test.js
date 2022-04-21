const {
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert,
    balance,
    time,
     // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');
  
  const staking = artifacts.require('Staking');
  const erc20 = artifacts.require('Token');

  var chai = require('chai');
  const BN = web3.utils.BN;
  const chaiBN = require('chai-bn')(BN);
  chai.use(chaiBN);

  var chaiAsPromised = require('chai-as-promised');
  chai.use(chaiAsPromised);

  const expect = chai.expect;

  contract('Staking', function ([sender, receiver]) {
      beforeEach(async () => {
        this.token = await erc20.new();
        this.val = new BN(10000)
        await this.token.mint(sender, this.val);
        await this.token.mint(receiver, this.val);
        this.staker = await staking.new(token.address);
        await this.token.mint(staker.address, this.val * 10);
        await this.token.approve(staker.address, this.val, {from:sender})
        await this.token.approve(staker.address, this.val, {from:receiver})
      })

    it('Should allow staking', async () => {
        const tx1 = await this.staker.stake(this.val, {from: receiver})
        let it = new BN(10000)
        expectEvent(tx1, "Stake", {
            _who: receiver,
            _amount: it,
        })
    });

    it('Should allow staking from multiple users', async () => {
        let it = new BN(10000)
        const tx1 = await this.staker.stake(this.val, {from: sender})

        expectEvent(tx1, "Stake", {
            _who: sender,
            _amount: it,
        })
        
        await time.advanceBlock();

        const tx2 = await this.staker.stake(this.val, {from: receiver})

        expectEvent(tx2, "Stake", {
            _who: receiver,
            _amount: it,
        })    
    });

    it('Contract state post-stake should be valid', async () => {
        await this.staker.stake(this.val, {from: sender})
        time.advanceBlock;

        let bal = await this.staker.bals(sender);
        expect(bal).to.be.a.bignumber.equal((this.val));
    });

    it('should not allow a zero stake', async () => {
        await expectRevert(this.staker.stake(0, {from:sender}), "stake more");
    });

    it('Should allow harvesting', async () => {
        const tx1 = await this.staker.stake(this.val, {from: sender})
        let it = new BN(10000)
        expectEvent(tx1, "Stake", {
            _who: sender,
            _amount: it,
        })
        time.advanceBlock();
        const rBal = await this.staker.getRewardsEarned(sender);
        const tx2 = await this.staker.harvest();

        expectEvent(tx2, "Harvest")
    });

    it('Should allow harvesting for two', async () => {
        let it = new BN(10000)

        const tx1 = await this.staker.stake(this.val, {from: sender})

        expectEvent(tx1, "Stake", {
            _who: sender,
            _amount: it,
        })

        time.advanceBlock();
        const tx3 = await this.staker.stake(this.val, {from: receiver})

        expectEvent(tx3, "Stake", {
            _who: receiver,
            _amount: it,
        })


        time.advanceBlock();
        const rBal = await this.staker.getRewardsEarned(sender);
    
        time.advanceBlock()
        const rBal2 = await this.staker.getRewardsEarned(receiver);

        time.advanceBlock()
        const tx2 = await this.staker.harvest({from:sender});

        expectEvent(tx2, "Harvest")
        
        time.advanceBlock();
        const tx4 = await this.staker.harvest({from:receiver});

        expectEvent(tx4, "Harvest")
    });
});