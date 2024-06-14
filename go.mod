module github.com/ajune0527/protoc-gen-go-gin

go 1.22

require (
	google.golang.org/genproto v0.0.0-20210223151946-22b48be4551b
	google.golang.org/protobuf v1.32.0
)

require github.com/golang/protobuf v1.5.0 // indirect

replace github.com/mohuishou/protoc-gen-go-gin => .
