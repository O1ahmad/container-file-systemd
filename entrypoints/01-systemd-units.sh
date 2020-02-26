#!/bin/bash

# Print all commands executed if DEBUG mode enabled
[ -n "${DEBUG:-""}" ] && set -x

systemd_name=${SYSTEMD_NAME}
systemd_path="${SYSTEMD_PATH:-/etc/systemd/system}"
systemd_type="${SYSTEMD_TYPE:-service}"
full_unit_path="${systemd_path}/${systemd_name}.${systemd_type}"

# Add Systemd unit provisioning header
echo "# Managed by 0xO1.IO" >> $full_unit_path
echo >> $full_unit_path

echo "[Unit]" >> $full_unit_path
for VAR in `env`
do
  if [[ "$VAR" =~ ^UNIT_ ]]; then
    property_name=`echo "$VAR" | sed -r "s/UNIT_(.*)=.*/\1/g" | tr _ .`
    property_value=`echo "UNIT_$property_name"`
    echo "$property_name=${!property_value}" >> $full_unit_path
  fi
done

# ** add unit section delimiter **
echo >> $full_unit_path

type_caps=`echo $systemd_type | tr '[:lower:]' '[:upper:]'`
type_section=`echo $systemd_type | tr '[:upper:]' '[:lower:]' | sed 's/\b./\u&/g'`
echo "[$type_section]" >> $full_unit_path
for VAR in `env`
do
  if [[ "$VAR" =~ ^${type_caps}_ ]]; then
    property_name=`echo "$VAR" | sed -r "s/${type_caps}_(.*)=.*/\1/g" | tr _ .`
    property_value=`echo "${type_caps}_$property_name"`
    echo "$property_name=${!property_value}" >> $full_unit_path
  fi
done

# ** add unit section delimiter **
echo >> $full_unit_path

echo "[Install]" >> $full_unit_path
for VAR in `env`
do
  if [[ "$VAR" =~ ^INSTALL_ ]]; then
    property_name=`echo "$VAR" | sed -r "s/INSTALL_(.*)=.*/\1/g" | tr _ .`
    property_value=`echo "INSTALL_$property_name"`
    echo "$property_name=${!property_value}" >> $full_unit_path
  fi
done

systemctl enable $systemd_name.$systemd_type
