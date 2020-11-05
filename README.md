# ApplySignedWithAttributeAndPermitExtended
Contract for Dai auto-swap when registering a project on Everest.

The function of sending ETH cannot be implemented in smart contact, so the calculation of the Dai balance, the calculation of the price and the required amount of ETH must be performed outside the contract. 
Unlike the applySignedWithAttributeAndPermit function of the Everest contract, _daiValue must be added to the parameters of the applySignedWithAttributeAndPermitDecorator function of this contract, and if there is a deficient of Dai, value(weiToSend) must be added.
