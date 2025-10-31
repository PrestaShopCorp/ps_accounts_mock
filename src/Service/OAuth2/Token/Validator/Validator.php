<?php

namespace PrestaShop\Module\PsAccounts\Service\OAuth2\Token\Validator;

class Validator
{
    /**
     * @param mixed $token
     */
    public function verifyToken($token)
    {
        print_r($token);
        die();
        return new DummyToken();
    }
}

class DummyToken
{
    public string $email = 'foo@bar.com';
}
