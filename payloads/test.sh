if [ -s payloads/mysql_password ]
then
  echo "[Starting to process MySQL/MariaDB user config...]"
  while read -r -a mysqlpass
  do
    if [ ${mysqlpass[0]} = "root" ]; then
      # Make sure that nobody can access the server without a password
      mysql -e "UPDATE mysql.user SET Password = PASSWORD('${mysqlpass[1]}') WHERE User = 'root';"
      echo mysql -e "UPDATE mysql.user SET Password WHERE User = 'root';"
      echo "[MySQL root password changed...]"
    elif [ ${mysqlpass[0]} = "backup" ]; then
      mysql -e "CREATE USER 'backup'@'localhost' IDENTIFIED BY ${mysqlpass[1]};"
      echo mysql -e "CREATE USER 'backup'@'localhost';"
      mysql -e "GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup'@'localhost';"
      echo mysql -e "GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup'@'localhost';"
      echo "[MySQL backup user created...]"
    fi
  done < payloads/mysql_password
fi
