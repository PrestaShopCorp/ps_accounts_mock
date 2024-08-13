<?php

if (!defined('_PS_VERSION_')) {
    exit;
}

class Ps_accounts extends Module
{
    /**
     * @var string
     */
    const VERSION = '1.1.0';

    /**
     * @var \PrestaShop\ModuleLibServiceContainer\DependencyInjection\ServiceContainer
     */
    private $serviceContainer;

    public function __construct()
    {
        $this->name = 'ps_accounts';
        $this->version = '1.1.0';
        $this->author = 'CloudSync team';
        $this->need_instance = 0;
        $this->ps_versions_compliancy = [
          'min' => '1.6.1.11',
          'max' => '99.99.99',
        ];
        $this->bootstrap = false;

        parent::__construct();

        $this->displayName = $this->l('PS Accounts Mock');
        $this->description = $this->l('Mocking');
        $this->confirmUninstall = $this->l('Are you sure you want to uninstall?');

        require_once __DIR__ . '/vendor/autoload.php';

        $this->serviceContainer = new \PrestaShop\ModuleLibServiceContainer\DependencyInjection\ServiceContainer(
            (string) $this->name,
            $this->getLocalPath()
        );
    }

    public function install()
    {
        $db = \Db::getInstance();
        $dbInstallFile = "{$this->getLocalPath()}/sql/install.sql";
        if (!file_exists($dbInstallFile))
        {
            return false;
        }

        $sql = \Tools::file_get_contents($dbInstallFile);
        if (empty($sql) || !is_string($sql))
        {
            return false;
        }
        $sql = str_replace(['PREFIX_', 'ENGINE_TYPE'], [_DB_PREFIX_, _MYSQL_ENGINE_], $sql);
        $sql = preg_split("/;\s*[\r\n]+/", trim($sql));
        if (!empty($sql))
        {
            foreach ($sql as $query) {
                if (!$db->execute($query)) {
                    return false;
                }
            }
        }
        return parent::install();
    }

    public function uninstall()
    {
        if (parent::uninstall() == false) {
            return false;
        }

        return true;
    }

    public function getService($serviceName)
    {
        return $this->serviceContainer->getService($serviceName);
    }
}
