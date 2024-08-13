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
     * Mock the original verifyToken
     * @deprecated
     * @see https://github.com/PrestaShopCorp/ps_accounts/blob/main/src/Api/Client/AccountsClient.php#L223
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
     * @see https://github.com/PrestaShopCorp/ps_accounts/blob/main/src/Api/Client/AccountsClient.php#L122
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
