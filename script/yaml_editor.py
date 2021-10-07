import sys
import yaml
from nob import Nob


def main(output, yamlFile, keyPath, value):
    # 읽기
    with open(yamlFile) as r:
        data = Nob(yaml.load(r, Loader=yaml.FullLoader))
        print("Input\t==> {}".format(yamlFile))

    # yaml file 변경
    data[keyPath] = value
    print('Edit\t==> key: {}, value: {}'.format(keyPath, value))

    # 쓰기
    with open(output, 'w') as w:
        yaml.dump(data[:], w)
        print("Output\t==> {}".format(output))


# cli에서 실행 시에만 변수 사용
# py 파일 파라미터를 제외하고 index 1부터 main 함수에 전달
#
# @param argv[0] Input py 파일
# @param argv[1] Output yaml 파일
# @param argv[2] 변경할 yaml 파일
# @param argv[3] 변경할 yaml key path
# @param argv[4] 변경할 yaml value
if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
