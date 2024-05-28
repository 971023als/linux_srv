#!/bin/bash

# 구성원이 존재하지 않는 그룹을 찾음
unnecessary_groups=($(awk -F: '($3>=500) && ($4=="") {print $1}' /etc/group))

# 불필요한 그룹이 없는지 확인
if [ ${#unnecessary_groups[@]} -eq 0 ]; then
    echo "※ U-51 결과 : 양호(Good) - 불필요한 그룹이 존재하지 않습니다."
    exit 0
fi

# 불필요한 그룹을 사용자에게 보여주고 제거 확인
echo "다음 그룹은 구성원이 존재하지 않습니다:"
for group in "${unnecessary_groups[@]}"; do
    echo "$group"
done

read -p "위 그룹을 모두 제거하시겠습니까? (y/N) " answer
case $answer in
    [Yy]* )
        for group in "${unnecessary_groups[@]}"; do
            groupdel "$group"
            if [ $? -eq 0 ]; then
                echo "$group 그룹을 성공적으로 제거하였습니다."
            else
                echo "$group 그룹 제거에 실패하였습니다."
            fi
        done
        ;;
    * )
        echo "그룹 제거가 취소되었습니다."
        ;;
esac
