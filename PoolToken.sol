// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
// use latest solidity version at time of writing, need not worry about overflow and underflow

/// @title ERC20 Contract - a liquidity pool token 
import "./ERC20_token/IERC20.sol";
//whoever constructs this contract is the only owner of the totalSupply of the tokens.
//in this project, it's the job of the Liquidity_pool contract to do so!
contract PoolToken is IERC20 {

    // My Variables
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupplyToken;

    // Keep track balances and allowances approved
    mapping(address => uint256) public balanceAccount;
    mapping(address => mapping(address => uint256)) public allowanceAccount;

    // Events - fire events on state changes etc
    //event Transfer(address indexed from, address indexed to, uint256 value);
    //event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint _decimals, uint _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupplyToken = _totalSupply; 
        balanceAccount[msg.sender] = totalSupplyToken;
    }

    
    function balanceOf(address account) override external view returns (uint256) {
        return balanceAccount[account];
    }
    
    function allowance(address owner, address spender) override external view returns (uint256) {
        return allowanceAccount[owner][spender];
    }
    function totalSupply() override external view returns (uint256) {
        return totalSupplyToken;
    }
    
    /// @notice transfer amount of tokens to an address
    /// @param _to receiver of token
    /// @param _value amount value of token to send
    /// @return success as true, for transfer 
    function transfer(address _to, uint256 _value) override external returns (bool success) {
        require(balanceAccount[msg.sender] >= _value);
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /// @dev internal helper transfer function with required safety checks
    /// @param _from, where funds coming the sender
    /// @param _to receiver of token
    /// @param _value amount value of token to send
    // Internal function transfer can only be called by this contract
    //  Emit Transfer Event event 
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Ensure sending is to valid address! 0x0 address cane be used to burn() 
        require(_to != address(0));
        balanceAccount[_from] = balanceAccount[_from] - (_value);
        balanceAccount[_to] = balanceAccount[_to] + (_value);
        emit Transfer(_from, _to, _value);
    }

    /// @notice Approve other to spend on your behalf eg an exchange 
    /// @param _spender allowed to spend and a max amount allowed to spend
    /// @param _value amount value of token to send
    /// @return true, success once address approved
    //  Emit the Approval event  
    // Allow _spender to spend up to _value on your behalf
    function approve(address _spender, uint256 _value) override external returns (bool) {
        require(_spender != address(0));
        allowanceAccount[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @notice transfer by approved person from original address of an amount within approved limit 
    /// @param _from, address sending to and the amount to send
    /// @param _to receiver of token
    /// @param _value amount value of token to send
    /// @dev internal helper transfer function with required safety checks
    /// @return true, success once transfered from original account    
    // Allow _spender to spend up to _value on your behalf
    function transferFrom(address _from, address _to, uint256 _value) override external returns (bool) {
        require(_value <= balanceAccount[_from]);
        require(_value <= allowanceAccount[_from][msg.sender]);
        allowanceAccount[_from][msg.sender] = allowanceAccount[_from][msg.sender] - (_value);
        _transfer(_from, _to, _value);
        return true;
    }

}
