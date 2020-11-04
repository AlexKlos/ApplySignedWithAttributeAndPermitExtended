pragma solidity =0.5.12;

/**
 The Dai contract does not have a balanceOf function, so it is imported in its entirety.
 */
import "./Dai.sol";


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint a, uint b) internal pure returns (uint) {
       // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }
}

/**
 Interface for accessing Everest smart contract functions. 
 */
interface Everest {
    function applySignedWithAttributeAndPermit(
        address _newMember,
        uint8[3] calldata _sigV,
        bytes32[3] calldata _sigR,
        bytes32[3] calldata _sigS,
        address _memberOwner,
        bytes32 _offChainDataName,
        bytes calldata _offChainDataValue,
        uint256 _offChainDataValidity
    ) external;
}

/**
 Interface for accessing UniswapV2Router02 smart contract functions. 
 */
interface UniswapV2Router02 {
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    
    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
}


/**
 ApplySignedWithAttributeAndPermitExtended contract contains a single function 
 applySignedWithAttributeAndPermitDecorator that is a decorator for the
 applySignedWithAttributeAndPermit function of the Everest contract.
 */
contract ApplySignedWithAttributeAndPermitExtended {
    // Everest contract instance
    Everest everest = Everest(0x445B774C012c5418d6D885f6cbfEB049a7FE6558);
    // UniswapV2Router02 contract instance
    UniswapV2Router02 uniswap = UniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    // Dai contract instance
    Dai dai = Dai(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    
    /**
     This function calls the applySignedWithAttributeAndPermit function 
     of the Everest contract and passes the argument values without modification. 
     But before that, it checks the Dai on the balance of the user's address and 
     if it is less than 10 dai, it calls the function swapETHForExactTokens 
     from the contract UniswapV2Router02 and swaps the required amount.
     */
    function applySignedWithAttributeAndPermitDecorator(
        address _newMember,
        uint8[3] calldata _sigV,
        bytes32[3] calldata _sigR,
        bytes32[3] calldata _sigS,
        address _memberOwner,
        bytes32 _offChainDataName,
        bytes calldata _offChainDataValue,
        uint256 _offChainDataValidity
    ) external payable {
        require(_newMember != address(0), "Member can't be 0 address");
        require(_memberOwner != address(0), "Owner can't be 0 address");
        
        if (dai.balanceOf(msg.sender) < 10000000000000000000) {
            uint _daiValue = SafeMath.sub(10000000000000000000, dai.balanceOf(msg.sender));
            address[] memory _path;
            // WETH contract address
            _path[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
            // Dai contract address
            _path[1] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
            uint _ethValue = uniswap.getAmountsIn(_daiValue, _path)[0];
            _ethValue += SafeMath.div(_ethValue, 100);
            uniswap.swapETHForExactTokens.value(_ethValue)(_daiValue, _path, msg.sender, SafeMath.add(block.timestamp, 600));
        }
        
        everest.applySignedWithAttributeAndPermit(_newMember, _sigV, _sigR, _sigS, _memberOwner, 
        _offChainDataName, _offChainDataValue, _offChainDataValidity);
    }
    
    /**
    Fallback function.
    */
    function () external payable {
        revert ();
    }
    
}