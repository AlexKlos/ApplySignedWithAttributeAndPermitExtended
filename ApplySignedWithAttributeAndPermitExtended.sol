

pragma solidity 0.6.6;


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

interface UniswapV2Router02 {
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts);
}


contract ApplySignedWithAttributeAndPermitExtended {
    everest = Everest(0x445B774C012c5418d6D885f6cbfEB049a7FE6558);
    uniswap = UniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    dai = Dai(0x6B175474E89094C44Da98b954EedeAC495271d0F)
    
    
    
}