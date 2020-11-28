package main
import(
  "fmt"
  "image"
  "image/color"
  "image/draw"
  "image/png"
  "log"
  "os"
  "time"
)

func main(){
  name := "Test"
  size := 200
  avatar, err :=createAvatar(size,initials)
  if err !=nil{
    log.Fatal(err)
  }
  

}
