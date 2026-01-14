#!/usr/bin/env bash

VA_FUNC='
sel_env() {
$HOME/.local/bin/sel_env_uv.sh
}
add_env(){
$HOME/.local/bin/python_env_uv.sh
}
del_env(){
$HOME/.local/bin/del_env_uv.sh
}
update_va(){
$HOME/.local/bin/update_va.sh
}
'

add_func() {
    local file="$1"

    [ -f "$file" ] || touch "$file"

    if grep -q "sel_env()" "$file"; then
        echo "[SKIP] 이미 존재: $file"
    else
        echo -e "\n# === Python venv selector (va) ===\n$VA_FUNC" >> "$file"
        echo "[OK] 추가 완료: $file"
    fi
}

cp $HOME/ExtUSB/Backup/SyncEnv/env_bash/sel_env_uv.sh $HOME/.local/bin/
cp $HOME/ExtUSB/Backup/SyncEnv/env_bash/python_env_uv.sh $HOME/.local/bin/
cp $HOME/ExtUSB/Backup/SyncEnv/env_bash/del_env_uv.sh $HOME/.local/bin/
cp $HOME/ExtUSB/rockchip_rk3588/ubuntu_setting/update_va.sh $HOME/.local/bin/

add_func "$HOME/.zshrc"
add_func "$HOME/.bashrc"

echo
echo "설정 완료. 새 터미널을 열거나 아래 실행:"
echo "  source ~/.zshrc"
echo "  source ~/.bashrc"
