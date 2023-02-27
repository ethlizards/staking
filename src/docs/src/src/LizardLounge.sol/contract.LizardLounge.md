# LizardLounge
[Git Source](https://github.com/kmaox/ethlizardstaking/blob/b10ad55b954f88c5d7150f56fb2c99a51bd77dfb/src/LizardLounge.sol)

**Inherits:**
ERC721, Ownable

**Author:**
kmao

Let's users stake their Ethlizard NFTs accuring comtimuous compound interest,
and also claim rewards based on their share of the pool.

*All pool and share values are stored in 1e18 form.*


## State Variables
### Ethlizards

```solidity
IEthlizards public Ethlizards;
```


### GenesisLiz

```solidity
IGenesisEthlizards public GenesisLiz;
```


### USDc

```solidity
IUSDc public USDc;
```


### MAXETHLIZARDID

```solidity
uint256 constant MAXETHLIZARDID = 5049;
```


### DEFAULTLIZARDSHARE

```solidity
uint256 constant DEFAULTLIZARDSHARE = 100 * 1e18;
```


### DAY

```solidity
uint256 constant DAY = 86400;
```


### originalLockedLizardOwners

```solidity
mapping(uint256 => address) public originalLockedLizardOwners;
```


### timeLizardLocked

```solidity
mapping(uint256 => uint256) public timeLizardLocked;
```


### stakePoolClaims

```solidity
mapping(uint256 => mapping(uint256 => bool)) stakePoolClaims;
```


### allowedContracts

```solidity
mapping(address => bool) public allowedContracts;
```


### pool

```solidity
Pool[] pool;
```


### depositsActive

```solidity
bool public depositsActive;
```


### councilAddress

```solidity
address public councilAddress;
```


### currentRewards

```solidity
uint256 public currentRewards;
```


### currentEthlizardStaked

```solidity
uint256 public currentEthlizardStaked;
```


### startTimestamp

```solidity
uint256 public startTimestamp;
```


### overallShare
timestamp for when deposits are first enabled


```solidity
uint256 public overallShare;
```


### currentRebases
tracks the overall share which is updated per deposit made


```solidity
uint256 public currentRebases = 0;
```


### minResetValue
how many times has the lizard rebased


```solidity
uint256 public minResetValue = 50000 * 1e6;
```


### resetCounter
TODO: check if this is 50,000 USDC


```solidity
uint256 public resetCounter;
```


### lastGlobalUpdate
tracks how many resets have occured


```solidity
uint256 public lastGlobalUpdate;
```


### resetShareValue

```solidity
uint256 public resetShareValue = 20;
```


## Functions
### constructor

*refers to a 80% slash*


```solidity
constructor(IEthlizards ethLizardsAddress, IGenesisEthlizards genesisLizaddress, IUSDc USDCAddress)
    ERC721("Locked Lizard", "LLZ");
```

### onlyApprovedContracts


```solidity
modifier onlyApprovedContracts(address operator);
```

### depositRegularStake

this is used for users to deposit their lizard/s


```solidity
function depositRegularStake(uint256[] memory _tokenIds) external;
```

### depositGenesisStake

we only use batchTransfer as it's the most gas-effective transfer function

updates the global total for shares

genesis nfts should have additional weight


```solidity
function depositGenesisStake(uint256[] memory _tokenIds) external;
```

### withdrawStake

we only use batchTransfer as it's the most gas-effective transfer function

updates the global total for shares

genesis lizards have 2x weight

works for both genesis and regular lizards


```solidity
function withdrawStake(uint256[] memory _tokenIds) external;
```

### claimReward

*we call this at the start this time as we need to make sure we change the correct rebased values later on*

*if runs if tokenId is a genesis*

*we reset locked values here*

*only runs if there are genesis tokens that here*


```solidity
function claimReward(uint256[] memory _tokenIds, uint256 _poolNumber) external;
```

### onERC721Received

calculate rewards


```solidity
function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4);
```

### retractLockedLizard

we want to give the original staker the ability to claim back their LLZ at any time


```solidity
function retractLockedLizard(uint256 _tokenId) public;
```

### depositRewards

*don't think using msg.sender here is as safe as this*


```solidity
function depositRewards(uint256 _depositAmount) public;
```

### batchTransferFrom

batch transfer function for LLZs


```solidity
function batchTransferFrom(address _from, address _to, uint256[] memory _tokenIds) public;
```

### isLizardWithdrawable


```solidity
function isLizardWithdrawable(uint256 _tokenId) public view returns (bool);
```

### isRewardsClaimed


```solidity
function isRewardsClaimed(uint256 _tokenId, uint256 _poolNumber) public view returns (bool);
```

### setApprovalForAll


```solidity
function setApprovalForAll(address operator, bool approved) public override onlyApprovedContracts(operator);
```

### approve


```solidity
function approve(address operator, uint256 tokenId) public override onlyApprovedContracts(operator);
```

### setAllowedContracts


```solidity
function setAllowedContracts(address _address, bool access) public onlyOwner;
```

### setResetValue


```solidity
function setResetValue(uint256 _newShareResetValue) public onlyOwner;
```

### setDepositsActive


```solidity
function setDepositsActive() public onlyOwner;
```

### whitelistCouncil


```solidity
function whitelistCouncil(address _councilAddress) public onlyOwner;
```

### setMinResetValue


```solidity
function setMinResetValue(uint256 newMinResetValue) public onlyOwner;
```

### getCurrentShareRaw

TODO: write this so the withdraw function is working


```solidity
function getCurrentShareRaw(uint256 _tokenId) public view returns (uint256);
```

### mintLLZ

this runs so we can find out what reset did the stake after (if any)


```solidity
function mintLLZ(uint256 _tokenId) internal;
```

### updateGlobalShares


```solidity
function updateGlobalShares() internal;
```

### resetGlobalShares


```solidity
function resetGlobalShares() internal;
```

### createPool


```solidity
function createPool(uint256 _value) internal;
```

### claimCalculation


```solidity
function claimCalculation(uint256 _tokenId, uint256 _poolNumber) internal view returns (uint256 owedAmount);
```

### calculateRebasePercentage

this runs so we can find out what reset did the stake after (if any)

*This is using the 64.64-bit fixed point number is basically a simple fraction whose numerator
is a signed 128-bit integer and denominator is 2^64. Thus this calculation is not exactly accurate
to 1.005, instead we use (1.8538977)×10^19÷2^64 ≈ 1.004999956952939976773109265 to resemble it.
We also multiply the nominator by 1e16 instead of 1e18, as 1e18 would lead to any rebases over 445 days
to overflow and revert. To convert the end result to a number that is in 1e18 format, we multiply
the last result by 1e2. Keep in mind when calling thhis function, you'll need to divide by 1e18.*


```solidity
function calculateRebasePercentage(uint256 _requiredRebases) internal pure returns (uint256);
```

### resetShareRaw


```solidity
function resetShareRaw(uint256 _currentShareRaw) internal view returns (uint256);
```

## Events
### LockedLizardMinted

```solidity
event LockedLizardMinted(address _mintedAddress, uint256 _mintedId);
```

### LockedLizardReMinted

```solidity
event LockedLizardReMinted(address _ownerAddress, uint256 _lizardId);
```

## Structs
### Pool

```solidity
struct Pool {
    uint256 time;
    uint256 value;
    uint256 currentGlobalShare;
}
```

