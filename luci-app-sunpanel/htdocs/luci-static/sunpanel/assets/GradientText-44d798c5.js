import{m as p,f as x,q as v,y as o,z as f,A as g,B as z,g as S,cH as T}from"./index-7e19b821.js";import{u as C}from"./index-2b595d91.js";import{f as R}from"./index-c238f14b.js";const $=p("gradient-text",`
 display: inline-block;
 font-weight: var(--n-font-weight);
 -webkit-background-clip: text;
 background-clip: text;
 color: #0000;
 white-space: nowrap;
 background-image: linear-gradient(var(--n-rotate), var(--n-color-start) 0%, var(--n-color-end) 100%);
 transition:
 --n-color-start .3s var(--n-bezier),
 --n-color-end .3s var(--n-bezier);
`),k=Object.assign(Object.assign({},f.props),{size:[String,Number],fontSize:[String,Number],type:{type:String,default:"primary"},color:[Object,String],gradient:[Object,String]}),O=x({name:"GradientText",props:k,setup(t){C();const{mergedClsPrefixRef:n,inlineThemeDisabled:l}=v(t),i=o(()=>{const{type:e}=t;return e==="danger"?"error":e}),m=o(()=>{let e=t.size||t.fontSize;return e&&(e=R(e)),e||void 0}),u=o(()=>{const e=t.color||t.gradient;if(typeof e=="string")return e;if(e){const s=e.deg||0,a=e.from,c=e.to;return`linear-gradient(${s}deg, ${a} 0%, ${c} 100%)`}}),h=f("GradientText","-gradient-text",$,T,t,n),d=o(()=>{const{value:e}=i,{common:{cubicBezierEaseInOut:s},self:{rotate:a,[g("colorStart",e)]:c,[g("colorEnd",e)]:y,fontWeight:b}}=h.value;return{"--n-bezier":s,"--n-rotate":a,"--n-color-start":c,"--n-color-end":y,"--n-font-weight":b}}),r=l?z("gradient-text",o(()=>i.value[0]),d,t):void 0;return{mergedClsPrefix:n,compatibleType:i,styleFontSize:m,styleBgImage:u,cssVars:l?void 0:d,themeClass:r==null?void 0:r.themeClass,onRender:r==null?void 0:r.onRender}},render(){const{mergedClsPrefix:t,onRender:n}=this;return n==null||n(),S("span",{class:[`${t}-gradient-text`,`${t}-gradient-text--${this.compatibleType}-type`,this.themeClass],style:[{fontSize:this.styleFontSize,backgroundImage:this.styleBgImage},this.cssVars]},this.$slots)}});export{O as N};
