const {expect} = require('chai');
const {ethers} = require('hardhat');

describe ('Market', async function(){

    let usdt, nft, market, accountA, accountB;

    beforeEach(async () =>{

        [accountA, accountB] = await ethers.getSigners();

        const USDT = await ethers.getContractFactory("cUSDT");
        usdt = await USDT.deploy();

        const MyNFT = await ethers.getContractFactory("NFTM");
        nft = await MyNFT.deploy(accountA.address);

        const Market = await ethers.getContractFactory("Market");
        market = await Market.deploy(usdt.target, nft.target);

        await nft.safeMint(accountB.address);
        await nft.safeMint(accountB.address);
        await nft.connect(accountB).setApprovalForAll(accountA.address, true);

        await usdt.approve(market.target, "1000000000000000000000000");

    });

    it('its erc20 address should be usdt', async function(){

        expect(await market.erc20()).to.equal(usdt.target);

    });

    it('its erc721 address should be nft', async function(){

        expect(await market.erc721()).to.equal(nft.target);

    });

    it('accountB should have two nfts', async () => {

        expect(await nft.balanceOf(accountB.address)).to.equal(2);

    });

    it('accountA should have usdt', async () => {

        expect(await usdt.balanceOf(accountA.address)).to.equal("100000000000000000000000000");

    });

    it('accountB can list two nfts to market', async () => {

        const price= "0x0000000000000000000000000000000000000000000000000001c6bf52634000";

        expect(await nft['safeTransferFrom(address, address, uint256, bytes)'](accountB.address, market.target, 0, price)).to.emit(market, "NewOrder");
        expect(await nft['safeTransferFrom(address, address, uint256, bytes)'](accountB.address, market.target, 1, price)).to.emit(market, "NewOrder");

        expect(await nft.balanceOf(accountB.address)).to.equal(0);
        expect(await nft.balanceOf(market.target)).to.equal(2);
        expect(await market.isListed(0)).to.equal(true);
        expect(await market.isListed(1)).to.equal(true);
        expect((await market.connect(accountB).getAllNFTs())[0][0]).to.equal(accountB.address);
        expect((await market.connect(accountB).getAllNFTs())[0][1]).to.equal(0);
        expect((await market.connect(accountB).getAllNFTs())[0][2]).to.equal(price);
        expect((await market.connect(accountB).getAllNFTs())[1][0]).to.equal(accountB.address);
        expect((await market.connect(accountB).getAllNFTs())[1][1]).to.equal(1);
        expect((await market.connect(accountB).getAllNFTs())[1][2]).to.equal(price);
        expect(await market.getOrderLength()).to.equal(2);
        expect((await market.connect(accountB).getMyNFTs())[0][0]).to.equal(accountB.address);
        expect((await market.connect(accountB).getMyNFTs())[0][1]).to.equal(0);
        expect((await market.connect(accountB).getMyNFTs())[0][2]).to.equal(price);

    });
    it('accountA can unlist one nft from market', async function() {
  const price = "0x0000000000000000000000000000000000000000000000000001c6bf52634000";
  
})

/*it('accountA can change price of nft from market', async function() {
  
})

it('accountB can buy nft from market', async function() {
  
})
it('accountA should have 0 nfts', async function() {
        expect(await nft.balanceOf(accountA.address)).to.equal(0);
      });
      */
it('accountB can remove one nft from market', async function () {
        it('accountB can remove one nft from market', async function() {
            const price = "0x0000000000000000000000000000000000000000000000000001c6bf52634000";
             // 列出NFT到市场
             await nft.connect(accountB).safeTransferFrom(accountB.address, market.address, 0, price);
             await nft.connect(accountB).safeTransferFrom(accountB.address, market.address, 1, price);
            // 验证市场状态
            expect(await market.isListed(0)).to.equal(true);
            expect(await market.isListed(1)).to.equal(true);
            expect(await market.getOrderLength()).to.equal(2);
    
            // 下架NFT
            await market.removeOrder(0);
            // 验证NFT是否成功下架
            expect(await market.isListed(0)).to.equal(false);
            expect(await market.isListed(1)).to.equal(true);
            expect(await market.getOrderLength()).to.equal(1);
        });
    });
    
      it('accountB can change price of nft from market', async function() {
        it('accountB can change price of nft from market', async function () {
            //上架一个nft
            await nft.connect(account1).safeTransferFrom(accountB.address, market.address, 0, "0x0000000000000000000000000000000000000000000000000DE0B6B3A7640000");
            // 更改NFT在市场上的价格 1 -> 0.5
            await market.changePrice(0, 500000000000000000);
            // 检查价格是否正确更新
            expect(await market.orderOfId(0).price).to.equal(500000000000000000);
          });
      });
      
      it('accountB can buy nft from market', async function() {
        it('accountB can buy nft from market', async function () {
            //上架一个nft 价格为1000000000000000000
            await nft.connect(accountB).safeTransferFrom(accountB.address, market.address, 0, "0x0000000000000000000000000000000000000000000000000DE0B6B3A7640000");
            // 从市场购买NFT
            await market.connect(accountA).buy(0, { value: await market.orderOfId(0).price });
            // 检查交易是否成功，NFT是否正确转移
            expect(await nft.ownerOf(0)).to.equal(accountB.address);
          });
      });
      it('accountA should have 0 nfts', async function() {
        expect(await nft.balanceOf(accountA.address)).to.equal(0);
      });


})

 