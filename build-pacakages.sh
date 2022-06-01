#!/usr/bin/bash
sudo chmod -R 777 "$(realpath "$(dirname "$0")")" 
cd "$(dirname "$0")" && mkdir repo
repoRootPath="$(realpath "$(dirname "$0")")/repo"
if [ "$USER" = "root" ]; then
    echo "请不要在 root 用户下使用本脚本，这是非常危险的，正在退出"
    exit 1
fi
scriptUsage="-w <路径>\t指定工作目录（默认位于当前目录的work文件夹下，请提供绝对或相对路径） \
  \n-a <指向软件列表的路径>\t指定AUR软件包列表,默认在当前目录下的aur.packages \
  -x <其他软件包的列表路径> \t默认位于目录下的other.packages。需要是git可以读取的路径并且其中要包含PKGBUILD,如https://example.com/example.git> \n \
  \n-h \t打印本条帮助信息"
echo "欢迎使用WNBO AUR脚本，使用 -h 来获得帮助"
workDir="$(realpath ./workDir)"
aurPackagesList="$(realpath ./aur.packages)"
otherPackagesList="$(realpath ./other.packages)"
while getopts "w:a:h" OPTION; do
    case "$OPTION" in
    "h")
        echo -e "$scriptUsage"
        ;;
    "w")
        filetype=$(file "$OPTARG")
        if [ "${filetype##*: }" = "directory" ]; then
            workDir="$(realpath "$OPTARG")"
        else
            echo -e "需要目录，但您提供的是${filetype##*: }类型的文件，请检查"
            exit 1
        fi
        ;;
    "a")
        aurPackagesList="$(realpath "$OPTARG")"
        ;;
    "x")
        otherPackagesList="$(realpath "$OPTARG")"
        ;;
    "?")
        echo "不支持的选项，自动忽略，输入-h来获取帮助"
        ;;
    esac
done
#开始获取AUR中的包
echo "$(grep -v '^$' $aurPackagesList)" >$aurPackagesList # 去除文件多余空行
mkdir "$workDir" -p ; cd "$workDir" ; mkdir AUR  ; cd AUR
for ((i = 1; i <= $(awk 'END {print NR}' "$aurPackagesList"); i++)); do
        package=$(head -"${i}" "$aurPackagesList" | tail -1)
        git clone "https://aur.archlinux.org/${package}.git"
        cd ./"${package}" &&
        makepkg --skippgpcheck --skipchecksums --noconfirm --syncdeps &&
        cp ./*.pkg.tar.zst  $repoRootPath
        cd ../
done
#获取其他软件包
echo "$(grep -v '^$' $otherPackagesList)" >$otherPackagesList # 去除文件多余空行
mkdir "$workDir" -p ; cd "$workDir" ; mkdir OTHER  ; cd OTHER
for ((i = 1; i <= $(awk 'END {print NR}' "$otherPackagesList"); i++)); do
        package=$(head -"${i}" "$otherPackagesList" | tail -1)
        echo ${package}
        git clone ${package} 
        dirGit=${package##*/}
        cd ./"${dirGit%%.*}" &&
        makepkg --skippgpcheck --skipchecksums --noconfirm --syncdeps &&
        cp ./*.pkg.tar.zst  $repoRootPath
        cd ../
done
rm -rf "$workDir"