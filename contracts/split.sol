//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;


import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';



contract Split is ERC721URIStorage{
    enum TokenState {Sold, Available}
    
    event Purchased(address _seller, address _buyer,uint256 _tokenId, uint256 _price);
    event Minted(address _owner, uint256 tokenId);
    uint256 public tokenCount;

   
    IERC20 stakeInstance;
    address admin;
    
    //struct for NFT created - contains NFT containing price, tokenURl and prize
    struct NFT {
        uint256 price;
        uint256 id;
        string  tokenURL;
        TokenState tokenState;
        
    }
    
    NFT[] AllNFTs; //an array of nft collections by Contract Owner
    mapping(uint256 => NFT) IdToNFT;
   
    
    
    modifier tokenExists(uint256 _id){
        require(_id <= tokenCount, 'token id does not exist');
        _;
    }
    
    modifier onlyAdmin(){
        require(msg.sender == admin, 'only admin can use this functionality');
        _;
    }
    
    constructor(address _stakeToken) ERC721('CoinVise', 'CVNTF') {
        stakeInstance = IERC20(_stakeToken);
        admin = msg.sender;
    }
    
    function mintAndSell(uint256 _amount_for_sale, string memory tokenURI)public onlyAdmin returns(uint256) {
        require(_amount_for_sale > 0, 'price should be more than 0');
        uint256 _tokenId = tokenCount + 1;
        tokenCount = _tokenId;
        _mint(msg.sender, _tokenId);
         _setTokenURI(_tokenId, tokenURI);
         
         NFT memory nft = NFT(_amount_for_sale, _tokenId, tokenURI, TokenState.Available);
         IdToNFT[_tokenId] = nft;
         
         AllNFTs.push(nft);
         emit Minted(admin, _tokenId);
        
        return _tokenId;
        
    }

   
    function purchase(uint256 _tokenId) external payable tokenExists(_tokenId) {
          require(IdToNFT[_tokenId].tokenState == TokenState.Available, 'this has been Sold');
        require(msg.value == IdToNFT[_tokenId].price, 'not enough eth was sent');
        
        address nftOwner = ownerOf(_tokenId);
        address buyer = msg.sender;
        safeTransferFrom(nftOwner, buyer, _tokenId);
         payable(address(this)).transfer(msg.value); // send the ETH to contract Address- which owner
         
         //set the NFt to Sold
         IdToNFT[_tokenId].tokenState = TokenState.Sold;
         //some $stake tokens must've been deposited to the contract, send 2 $stake to buyer
         stakeInstance.transfer(msg.sender, 2 * 10**18);
         
        emit Purchased(nftOwner, buyer, _tokenId, msg.value);
    }
    
   
    
    function contractEtherBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function contractStakeBalance()public view returns(uint256){
        return stakeInstance.balanceOf(address(this));
    }
    
    function viewNftOwner(uint256 _tokenId)public tokenExists(_tokenId) view returns(address){
        return ownerOf(_tokenId);
    }
    
    receive() external payable {
    }
    
    function allNFTs()public view returns(NFT[] memory){
        return AllNFTs;
    }
    
    function withdrawStakeToken(address _to, uint256 _amount)public onlyAdmin{
        //admin might want to withdraw some stake tokens he had deposited to the contract
        require(_amount <= stakeInstance.balanceOf(address(this)), 'not enough $stake in contract');
        stakeInstance.transfer(_to, _amount);
        
    }
    
    
    //function that splits contract eth Balance between 2 addresses holding atleast 10,000 $stake
    //any one can call thia function
    function splitContractEth(address[] memory _stakeHolders, address[] memory _topHolders)public payable{
        require(msg.sender == admin, 'only admin please');
        require(_topHolders.length == 5, 'top holders should be 5');
        //split eth balance in contract to 50% for the 2 stakeholders
        uint256 contractEthBalance = address(this).balance;
        uint256 ownerPortion = contractEthBalance * 10/100;
        uint256 _allStakeHoldersPortion = contractEthBalance * 10/100;
        uint256 _allTopHoldersPortion = contractEthBalance - (ownerPortion + _allStakeHoldersPortion);
        
        
        //transfer 10% of ethBalance to admin
        payable(admin).transfer(ownerPortion);
        
        //split _allStakeHoldersPortion equally among 
        for(uint256 i =0; i < _stakeHolders.length; i++){
            //all stake holders should hold atleast 10,000 $Stake
          require(stakeInstance.balanceOf(_stakeHolders[i]) >= 10000 * 10**18, 'only stake holder addresses(with atleast 10,000 $Stake) can recieve a share of contract eth');
            payable(_stakeHolders[i]).transfer(_allStakeHoldersPortion/_stakeHolders.length);
        }
        
        //split  _allTopHoldersPortion equally among top 5 holders- say with balance of atleast 50,000  $Stake
         for(uint256 i =0; i < _topHolders.length; i++){
            //all stake holders should hold atleast 10,000 $Stake
          require(stakeInstance.balanceOf(_topHolders[i]) >= 50000 * 10**18, 'only stake holder addresses(with atleast 50,000 $Stake) can recieve a share of contract eth');
            payable(_stakeHolders[i]).transfer(_allTopHoldersPortion/_topHolders.length);
        }
        
    }
    
    
}

