<?php
namespace PrestaShop\Module\PsAccounts\Api\Client;

/**
 * Class ServicesAccountsClient mock
 */
class AccountsClient
{
    /**
     * ServicesAccountsClient constructor.
     */
    public function __construct()
    {
    }

    /**
     * Mock the original PS Accounts client
     * @see https://github.com/PrestaShopCorp/ps_accounts/blob/master/src/Api/Client/AccountsClient.php#L221
     * @return array response
     */
    public function verifyToken()
    {
      return [
        "status" => true,
        "httpCode" => 200,
        "body" => null
      ];
    }

    /**
     * Mock the original RefreshShopToken 
     * @see https://github.com/PrestaShopCorp/ps_accounts/blob/master/src/Api/Client/AccountsClient.php#L106C21-L106C37
     * @return array response
     */
    public function refreshShopToken()
    {
      return [
        "status" => false,
        "httpCode" => 400,
        "body"=> [
          "message" => "Cannot refresh token"
        ]        
      ];
    }
}
