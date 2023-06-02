// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// PUSH Comm Contract Interface
interface IPUSHCommInterface {
    function sendNotification(address _channel, address _recipient, bytes calldata _identity) external;
}

contract PushTokenDemo is ERC20 {

    using Strings for address;
    using Strings for uint;

    // EPNS COMM ADDRESS ON ETHEREUM KOVAN, CHECK THIS: https://docs.epns.io/developers/developer-tooling/epns-smart-contracts/epns-contract-addresses
    address public EPNS_COMM_ADDRESS = 0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa; // This is Mumbai Comms

    constructor() ERC20("Push Token Demo", "PUSHDEMO") {
        _mint(msg.sender, 1000 * 10 ** uint(decimals()));
    }

    function transfer(address to, uint amount) override public returns (bool success) {
        address owner = _msgSender();
        _transfer(owner, to, amount);

        //"0+3+Hooray! ", msg.sender, " sent ", token amount, " PUSH to you!"
        IPUSHCommInterface(EPNS_COMM_ADDRESS).sendNotification(
            INSERT_CHANNEL_ADDRESS_HERE, // from channel
            to, // to recipient, put address(this) in case you want Broadcast or Subset. For Targetted put the address to which you want to send
            bytes(
                string(
                    // We are passing identity here: https://docs.push.org/developers/developer-guides/sending-notifications/notification-payload-types/notification-standard-advanced/notification-identity
                    abi.encodePacked(
                        "0", // this is notification identity: https://docs.push.org/developers/developer-guides/sending-notifications/notification-payload-types/notification-standard-advanced/notification-identity
                        "+", // segregator
                        "3", // this is payload type: https://docs.push.org/developers/developer-guides/sending-notifications/notification-payload-types/notification-standard-advanced/notification-payload (1, 3 or 4) = (Broadcast, targetted or subset)
                        "+", // segregator
                        "Tranfer Alert", // this is notificaiton title
                        "+", // segregator
                        "Hooray! ", // notification body
                        msg.sender.toHexString(), // notification body
                        " sent ", // notification body
                        (amount / (10 ** uint(decimals()))).toString(), // notification body
                        " PUSH to you!" // notification body
                    )
                )
            )
        );
        
        return true;
    }

}
