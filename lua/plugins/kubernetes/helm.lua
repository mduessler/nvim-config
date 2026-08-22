-- Proper filetype and highlighting for helm templates. Buffers get
-- ft=helm, which also keeps yamlls away from go-templated yaml.
return {
	"towolf/vim-helm",
	ft = "helm",
}
