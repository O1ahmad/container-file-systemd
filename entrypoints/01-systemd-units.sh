#!/bin/bash

# Print all commands executed if DEBUG mode enabled
[ -n "${DEBUG:-""}" ] && set -x

systemd_name=${SYSTEMD_NAME}
systemd_path="${SYSTEMD_PATH:-/etc/systemd/system}"
systemd_type="${SYSTEMD_TYPE:-service}"
full_unit_path="${systemd_path}/${systemd_name}.${systemd_type}"

echo "[Unit]" >> $full_unit_path
for VAR in `env`
do
  if [[ "$VAR" =~ ^UNIT_ ]]; then
    property_name=`echo "$VAR" | sed -r "s/UNIT_(.*)=.*/\1/g" | tr _ .`
    property_value=`echo "UNIT_$property_name"`
    echo "`echo $property_name | tr '[:upper:]' '[:lower:]' | sed 's/\b./\u&/g'`=${!property_value}"
    echo "`echo $property_name | tr '[:upper:]' '[:lower:]' | sed 's/\b./\u&/g'`=${!property_value}" >> $full_unit_path
  fi
done

echo >> $full_unit_path

echo "[Install]" >> $full_unit_path
for VAR in `env`
do
  if [[ "$VAR" =~ ^INSTALL_ ]]; then
    property_name=`echo "$VAR" | sed -r "s/INSTALL_(.*)=.*/\1/g" | tr _ .`
    property_value=`echo "INSTALL_$property_name"`
    echo "`echo $property_name | tr '[:upper:]' '[:lower:]' | sed 's/\b./\u&/g'`=${!property_value}"
    echo "`echo $property_name | tr '[:upper:]' '[:lower:]' | sed 's/\b./\u&/g'`=${!property_value}" >> $full_unit_path
  fi
done
