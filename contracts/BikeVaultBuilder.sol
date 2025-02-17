// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {ERC721PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BikeVaultBuilder is Initializable, ERC721Upgradeable,ERC721EnumerableUpgradeable,
 ERC721PausableUpgradeable, OwnableUpgradeable,
  ERC721BurnableUpgradeable, UUPSUpgradeable {
    uint256 private _nextTokenId;
bool public publicMintOpen =false;
bool public allowListMintOpen =false;


    mapping(address=>bool) public allowList;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
         _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __ERC721_init("BikeVaultBuilder", "BVBT");
        __ERC721Enumerable_init();
        __ERC721Pausable_init();
        __Ownable_init(initialOwner);
        __ERC721Burnable_init();
         __UUPSUpgradeable_init();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "0xc61cf7338cfe177e0334b576d203b50273175be9";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }


 function setAllowList(address [] calldata addresses) external onlyOwner{
    for(uint256 i=0; i<addresses.length; i++){
            allowList[addresses[i]]=true;
    }
 }


 function addToAllowList(address _address) external onlyOwner{
            require(allowList[_address]=false,"Already added to the allowedList");
            allowList[_address]=true;
 }

 function removeFromAllowList(address _address) external onlyOwner{
        require(allowList[_address]=true,"Address is not in the allowedList");
            allowList[_address]=false;
 }


    // add payment. payabla allows us to receive money 
    function publicMint() public payable  {
         require(publicMintOpen,"Public Mint Closed");
        require(msg.value == 0.001 ether, "Not Enough funds");
         internalMint();
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721PausableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }




//add public mint and allowance and allowLitMintOpen variavbels
//required people need to be added to a list array as whitelist
    function allowListMint() public payable  {
        require(allowListMintOpen,"Allowlist Mint Closed");
        require(allowList[msg.sender],"You arenot allowed to mint");
        require(msg.value == 0.0001 ether, "Not Enough Funds");
        internalMint();
    }


    function editMintWindows(bool _publicMintOpen,bool _allowListMintOpen) external onlyOwner{
            allowListMintOpen=_allowListMintOpen;
            publicMintOpen = _publicMintOpen;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
    
    function test() public pure returns(string memory){
        return "Bike Contract";
    }

    function internalMint() internal {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }


 function withdraw(address _addr) external onlyOwner{
    uint256 balance = address(this).balance;
    payable(_addr).transfer(balance);
 }

}