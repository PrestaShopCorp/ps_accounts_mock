INSERT INTO `PREFIX_configuration` (
  id_configuration,
  id_shop_group,
  id_shop,
  name,
  value,
  date_add,
  date_upd)
VALUES (NULL, NULL, NULL, "PSX_UUID_V4", "f07181f7-2399-406d-9226-4b6c14cf6068", NOW(), NOW())
ON DUPLICATE KEY UPDATE
  value = VALUES(value),
  date_upd = VALUES(date_upd);