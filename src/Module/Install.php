<?php
namespace PrestaShop\Module\PsAccounts\Module;

class Install
{
    public const PARENT_TAB_NAME = -1;
    public const TAB_ACTIVE = 0;

    /**
     * @var \Ps_accounts
     */
    private $module;
    /**
     * @var \Db
     */
    private $db;

    public function __construct(\Ps_accounts $module, \Db $db)
    {
        $this->module = $module;
        $this->db = $db;
    }

    /**
     * Installs database tables
     *
     * @return bool
     */
    public function installDatabaseTables()
    {
        $dbInstallFile = "{$this->module->getLocalPath()}/sql/install.sql";
        if (!file_exists($dbInstallFile)) {
            return false;
        }

        $sql = \Tools::file_get_contents($dbInstallFile);
        if (empty($sql) || !is_string($sql)) {
            return false;
        }

        $sql = str_replace(['PREFIX_', 'ENGINE_TYPE'], [_DB_PREFIX_, _MYSQL_ENGINE_], $sql);
        $sql = preg_split("/;\s*[\r\n]+/", trim($sql));

        if (!empty($sql)) {
            foreach ($sql as $query) {
                if (!$this->db->execute($query)) {
                    return false;
                }
            }
        }
        return true;
    }
}
