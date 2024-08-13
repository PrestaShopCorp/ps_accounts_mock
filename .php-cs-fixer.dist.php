<?php

$finder = (new PhpCsFixer\Finder())
    ->in(__DIR__)
    ->exclude('prestashop')
    ->exclude('dist')
    ->exclude('tools')
    ->exclude('vendor');

$config = (new PrestaShop\CodingStandards\CsFixer\Config())
    ->setUsingCache(false)
    ->setFinder($finder);

return $config;
