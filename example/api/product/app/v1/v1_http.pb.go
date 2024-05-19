// Code generated by protoc-gen-go-gin. DO NOT EDIT.
// versions:
// protoc-gen-go-gin

package v1

import (
	context "context"
	ext "github.com/ajune0527/golibs/ext"
	gin "github.com/gin-gonic/gin"
	errors "github.com/go-kratos/kratos/v2/errors"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the kratos package it is being compiled against.
// context.gin.errors.ext.

type BlogServiceHTTPServer interface {
	CreateArticle(context.Context, *Article) (*Article, error)
	GetArticles(context.Context, *GetArticlesReq) (*GetArticlesResp, error)
}

type BlogService struct {
	server      BlogServiceHTTPServer
	router      gin.IRouter
	middlewares []gin.HandlerFunc
	resp        ext.Response
}

func (r *BlogService) RegisterService() {
	r.router.GET("/v1/articles", append(r.middlewares, r.GetArticles)...)
	r.router.POST("/v1/author/:author_id/articles", append(r.middlewares, r.CreateArticle)...)
}

func (r *BlogService) Validate(in interface{}) error {
	if v, ok := in.(interface{ Validate() error }); ok {
		if err := v.Validate(); err != nil {
			return err
		}
	}
	return nil
}

func RegisterBlogServiceHTTPServer(r gin.IRouter, srv BlogServiceHTTPServer, resp ext.Response, middlewares ...gin.HandlerFunc) {
	s := &BlogService{
		server:      srv,
		router:      r,
		resp:        resp,
		middlewares: middlewares,
	}
	s.RegisterService()
}

func (r *BlogService) GetArticles(ctx *gin.Context) {
	var in GetArticlesReq
	c := ext.NewContext(ctx)
	if err := c.ShouldBindQuery(&in); err != nil {
		r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
		return
	}

	if err := r.Validate(&in); err != nil {
		r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
		return
	}

	out, err := r.server.GetArticles(c.Request.Context(), &in)
	if err != nil {
		r.resp.Error(c, err)
		return
	}
	r.resp.Success(c, out)
	return
}

func (r *BlogService) CreateArticle(ctx *gin.Context) {
	var in Article
	c := ext.NewContext(ctx)
	if err := c.ShouldBindQuery(&in); err != nil {
		r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
		return
	}
	if err := c.ShouldBindUri(&in); err != nil {
		r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
		return
	}

	if err := r.Validate(&in); err != nil {
		r.resp.Error(c, errors.BadRequest("InvalidParameter", err.Error()))
		return
	}

	out, err := r.server.CreateArticle(c.Request.Context(), &in)
	if err != nil {
		r.resp.Error(c, err)
		return
	}
	r.resp.Success(c, out)
	return
}