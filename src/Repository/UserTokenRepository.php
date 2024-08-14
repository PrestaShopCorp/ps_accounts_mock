<?php

namespace PrestaShop\Module\PsAccounts\Repository;

class UserTokenRepository
{
    public function __construct()
    {
    }

    /**
     * @return string
     */
    public function getOrRefreshToken()
    {
        return 'token';
    }
}
