//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';



contract Split is ERC721{
    event Purchased(address _seller, address _buyer,uint256 _tokenId, uint256 _price);
    uint256 public tokenCount;

    mapping (uint256 => uint256) public tokenIdToPrice; //maps price for each nft 
    
   
    IERC20 stakeInstance;

    constructor(address _stakeToken) ERC721('CoinVise', 'CVNTF') {
        stakeInstance = IERC20(_stakeToken);
    }
    
    function mintAndSell(uint256 _amount_for_sale)public returns(uint256) {
        uint256 _tokenId = tokenCount + 1;
        tokenCount = _tokenId;
        _mint(msg.sender, _tokenId);
         require(_amount_for_sale > 0, 'price should be more than 0');
        tokenIdToPrice[_tokenId] = _amount_for_sale;
        return _tokenId;
        
    }

   
    function purchase(uint256 _tokenId) external payable {
         
        require(msg.value == tokenIdToPrice[_tokenId] , 'not enough eth was sent');
        
        address nftOwner = ownerOf(_tokenId);
        address buyer = msg.sender;
        safeTransferFrom(nftOwner, buyer, _tokenId);
         payable(address(this)).transfer(msg.value); // send the ETH to the seller
        emit Purchased(nftOwner, buyer, _tokenId, msg.value);
    }
    
    function stakeBal(address _staker)public view returns(uint256){
        return stakeInstance.balanceOf(_staker);
    }
    
    function contractEthBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function viewNftOwner(uint256 _tokenId)public view returns(address){
        return ownerOf(_tokenId);
    }
    
    receive() external payable {
    }
    
    
    //function that splits contract eth Balance between 2 addresses holding atleast 10,000 $stake
    //any one can call thia function
    function splitContractEth(address[] memory _stakeHolders)public payable{
        require(_stakeHolders.length == 2, 'only 2 stakeholders required to split funds');
        //split eth balance in contract to 50% for the 2 stakeholders
        uint256 fiftyPercent = address(this).balance / 2;
        
        
        for(uint256 i =0; i < _stakeHolders.length; i++){
          require(stakeInstance.balanceOf(_stakeHolders[i]) >= 10000 * 10**18, 'only stake holder addresses(with atleast 10,000 $Stake) can recieve a share of contract eth');
            payable(_stakeHolders[i]).transfer(fiftyPercent);
        }
        
    }
    
    
}

