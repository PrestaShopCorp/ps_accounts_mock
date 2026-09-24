<?php

namespace PrestaShop\Module\PsAccounts\Service\OAuth2\Token\Validator;

class Validator
{
    /**
     * @param mixed $token
     */
    public function verifyToken($token)
    {
        return new DummyToken();
    }
}

class DummyToken
{
    /**
     * @var string
     */
    public $email = 'foo@bar.com';
}
