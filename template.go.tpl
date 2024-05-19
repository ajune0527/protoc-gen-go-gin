{{$svrType := .ServiceType}}
{{$svrName := .ServiceName}}
type {{.ServiceType}}HTTPServer interface {
{{- range .MethodSets}}
    {{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{- end}}
}

type {{$svrType}} struct{
server {{.ServiceType}}HTTPServer
router gin.IRouter
middlewares []gin.HandlerFunc
resp   ext.Response
}

func (r *{{$svrType}}) RegisterService(){
{{- range .Methods}}
    r.router.{{.Method}}("{{.Path}}", append(r.middlewares, r.{{.Name}}{{if not (eq .Num 0)}}{{.Num}}{{end}})...)
{{- end}}
}

func (r *{{$svrType}}) Validate(in interface{}) error {
if v, ok := in.(interface{ Validate() error }); ok {
if err := v.Validate(); err != nil {
return err
}
}
return nil
}

func Register{{.ServiceType}}HTTPServer(r gin.IRouter, srv {{.ServiceType}}HTTPServer,resp ext.Response, middlewares ...gin.HandlerFunc) {
s := &{{$svrType}}{
server: srv,
router: r,
resp:   resp,
middlewares: middlewares,
}
s.RegisterService()
}

{{range .Methods}}
    func (r *{{$svrType}}) {{.Name}}{{if not (eq .Num 0)}}{{.Num}}{{end}}(ctx *gin.Context) {
    var in {{.Request}}
	c := ext.NewContext(ctx)
    {{- if .HasBody}}
        {{- if not (eq .Request "emptypb.Empty")}}
            if err := c.ShouldBindJSON(&in{{.Body}}); err != nil {
            r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
            return
            }
        {{- end}}
        {{- if isBindQuery .Path }}
            if err := c.ShouldBindQuery(&in); err != nil {
            r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
            return
            }
        {{- end}}
    {{- else}}
        {{- if not (eq .Request "emptypb.Empty")}}
            if err := c.ShouldBindQuery(&in{{.Body}}); err != nil {
            r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
            return
            }
        {{- end}}
    {{- end}}
    {{- if .HasVars}}
        if err := c.ShouldBindUri(&in); err != nil {
        r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
        return
        }
    {{- end}}
    {{- if not (eq .Request "emptypb.Empty")}}

        if err := r.Validate(&in); err != nil {
        r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
        return
        }
    {{- end}}
    {{- if eq .Reply "emptypb.Empty"}}

        _, err := r.server.{{.Name}}(c.Request.Context(), &in)
        if err != nil {
        r.resp.Error(c, err)
        return
        }
        return
    {{- else if eq .Reply "httpbody.HttpBody"}}

        out, err := r.server.{{.Name}}(c.Request.Context(), &in)
        if err != nil {
        r.resp.Error(c, err)
        return
        }
        c.Header("Content-Type", out.ContentType)
        c.Writer.Write(out.Data)
        nil
        return
    {{- else}}

        out, err := r.server.{{.Name}}(c.Request.Context(), &in)
        if err != nil {
        r.resp.Error(c, err)
        return
        }
        r.resp.Success(c, out)
        return
    {{- end}}
    }
{{end}}