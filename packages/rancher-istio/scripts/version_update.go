package main
import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"flag"
)

func updateFiles(path string, currentIstio string, newIstio string, currentKiali string, newKiali string) error {
	read, err := ioutil.ReadFile(path)
	if err != nil {
		panic(err)
	}
	fmt.Println(path)
	if currentIstio != "" && newIstio != "" {
		err := replaceAndWrite(read, path, currentIstio, newIstio)
		if err != nil{
			return err
		}
	}

	if currentKiali != "" && newKiali != "" {
		err := replaceAndWrite(read, path, currentKiali, newKiali)
		if err != nil{
			return err
		}
	}
	return nil
}

func replaceAndWrite(read []byte, path string, old string, new string ) error {
	newContents := strings.Replace(string(read), old, new, -1)
	fmt.Println(newContents)
	return ioutil.WriteFile(path, []byte(newContents), 0)
}

func main() {
	currentIstio := flag.String("ci", "", "The current version of istio")
	newIstio := flag.String("ni", "", "The new version of istio")
	currentKiali := flag.String("ck", "", "The current version of kiali")
	newKiali := flag.String("nk", "", "The new version of kiali")
	flag.Parse()
	wd, err := os.Getwd()
	if err != nil {
		panic (err)
	}
	err = updateFiles(fmt.Sprintf("%s/packages/rancher-istio/charts/values.yaml", wd), *currentIstio, *newIstio, *currentKiali, *newKiali)
	if err != nil {
		panic(err)
	}
	err = updateFiles(fmt.Sprintf("%s/packages/rancher-istio/charts/Chart.yaml", wd), *currentIstio, *newIstio, *currentKiali, *newKiali)
	if err != nil {
		panic(err)
	}
	err = updateFiles(fmt.Sprintf("%s/packages/rancher-istio/charts/requirements.yaml", wd), *currentIstio, *newIstio, *currentKiali, *newKiali)
	if err != nil {
		panic(err)
	}
}