import{m as d,p as t,K as v,aT as F,n as H,f as j,q as M,z as C,af as N,y as p,aN as O,A as i,B as V,r as W,g as o,P as D,aL as K,F as q,G,aS as J,cT as Q,S as U,aD as X,aE as Y,aF as Z,aC as ee}from"./index-7e19b821.js";const re=d("alert",`
 line-height: var(--n-line-height);
 border-radius: var(--n-border-radius);
 position: relative;
 transition: background-color .3s var(--n-bezier);
 background-color: var(--n-color);
 text-align: start;
 word-break: break-word;
`,[t("border",`
 border-radius: inherit;
 position: absolute;
 left: 0;
 right: 0;
 top: 0;
 bottom: 0;
 transition: border-color .3s var(--n-bezier);
 border: var(--n-border);
 pointer-events: none;
 `),v("closable",[d("alert-body",[t("title",`
 padding-right: 24px;
 `)])]),t("icon",{color:"var(--n-icon-color)"}),d("alert-body",{padding:"var(--n-padding)"},[t("title",{color:"var(--n-title-text-color)"}),t("content",{color:"var(--n-content-text-color)"})]),F({originalTransition:"transform .3s var(--n-bezier)",enterToProps:{transform:"scale(1)"},leaveToProps:{transform:"scale(0.9)"}}),t("icon",`
 position: absolute;
 left: 0;
 top: 0;
 align-items: center;
 justify-content: center;
 display: flex;
 width: var(--n-icon-size);
 height: var(--n-icon-size);
 font-size: var(--n-icon-size);
 margin: var(--n-icon-margin);
 `),t("close",`
 transition:
 color .3s var(--n-bezier),
 background-color .3s var(--n-bezier);
 position: absolute;
 right: 0;
 top: 0;
 margin: var(--n-close-margin);
 `),v("show-icon",[d("alert-body",{paddingLeft:"calc(var(--n-icon-margin-left) + var(--n-icon-size) + var(--n-icon-margin-right))"})]),v("right-adjust",[d("alert-body",{paddingRight:"calc(var(--n-close-size) + var(--n-padding) + 2px)"})]),d("alert-body",`
 border-radius: var(--n-border-radius);
 transition: border-color .3s var(--n-bezier);
 `,[t("title",`
 transition: color .3s var(--n-bezier);
 font-size: 16px;
 line-height: 19px;
 font-weight: var(--n-title-font-weight);
 `,[H("& +",[t("content",{marginTop:"9px"})])]),t("content",{transition:"color .3s var(--n-bezier)",fontSize:"var(--n-font-size)"})]),t("icon",{transition:"color .3s var(--n-bezier)"})]),oe=Object.assign(Object.assign({},C.props),{title:String,showIcon:{type:Boolean,default:!0},type:{type:String,default:"default"},bordered:{type:Boolean,default:!0},closable:Boolean,onClose:Function,onAfterLeave:Function,onAfterHide:Function}),ie=j({name:"Alert",inheritAttrs:!1,props:oe,setup(n){const{mergedClsPrefixRef:e,mergedBorderedRef:l,inlineThemeDisabled:g,mergedRtlRef:u}=M(n),h=C("Alert","-alert",re,Q,n,e),z=N("Alert",u,e),f=p(()=>{const{common:{cubicBezierEaseInOut:a},self:r}=h.value,{fontSize:x,borderRadius:R,titleFontWeight:I,lineHeight:A,iconSize:T,iconMargin:m,iconMarginRtl:$,closeIconSize:w,closeBorderRadius:P,closeSize:B,closeMargin:S,closeMarginRtl:_,padding:L}=r,{type:s}=n,{left:k,right:E}=O(m);return{"--n-bezier":a,"--n-color":r[i("color",s)],"--n-close-icon-size":w,"--n-close-border-radius":P,"--n-close-color-hover":r[i("closeColorHover",s)],"--n-close-color-pressed":r[i("closeColorPressed",s)],"--n-close-icon-color":r[i("closeIconColor",s)],"--n-close-icon-color-hover":r[i("closeIconColorHover",s)],"--n-close-icon-color-pressed":r[i("closeIconColorPressed",s)],"--n-icon-color":r[i("iconColor",s)],"--n-border":r[i("border",s)],"--n-title-text-color":r[i("titleTextColor",s)],"--n-content-text-color":r[i("contentTextColor",s)],"--n-line-height":A,"--n-border-radius":R,"--n-font-size":x,"--n-title-font-weight":I,"--n-icon-size":T,"--n-icon-margin":m,"--n-icon-margin-rtl":$,"--n-close-size":B,"--n-close-margin":S,"--n-close-margin-rtl":_,"--n-padding":L,"--n-icon-margin-left":k,"--n-icon-margin-right":E}}),c=g?V("alert",p(()=>n.type[0]),f,n):void 0,b=W(!0),y=()=>{const{onAfterLeave:a,onAfterHide:r}=n;a&&a(),r&&r()};return{rtlEnabled:z,mergedClsPrefix:e,mergedBordered:l,visible:b,handleCloseClick:()=>{var a;Promise.resolve((a=n.onClose)===null||a===void 0?void 0:a.call(n)).then(r=>{r!==!1&&(b.value=!1)})},handleAfterLeave:()=>{y()},mergedTheme:h,cssVars:g?void 0:f,themeClass:c==null?void 0:c.themeClass,onRender:c==null?void 0:c.onRender}},render(){var n;return(n=this.onRender)===null||n===void 0||n.call(this),o(J,{onAfterLeave:this.handleAfterLeave},{default:()=>{const{mergedClsPrefix:e,$slots:l}=this,g={class:[`${e}-alert`,this.themeClass,this.closable&&`${e}-alert--closable`,this.showIcon&&`${e}-alert--show-icon`,!this.title&&this.closable&&`${e}-alert--right-adjust`,this.rtlEnabled&&`${e}-alert--rtl`],style:this.cssVars,role:"alert"};return this.visible?o("div",Object.assign({},D(this.$attrs,g)),this.closable&&o(K,{clsPrefix:e,class:`${e}-alert__close`,onClick:this.handleCloseClick}),this.bordered&&o("div",{class:`${e}-alert__border`}),this.showIcon&&o("div",{class:`${e}-alert__icon`,"aria-hidden":"true"},q(l.icon,()=>[o(U,{clsPrefix:e},{default:()=>{switch(this.type){case"success":return o(ee,null);case"info":return o(Z,null);case"warning":return o(Y,null);case"error":return o(X,null);default:return null}}})])),o("div",{class:[`${e}-alert-body`,this.mergedBordered&&`${e}-alert-body--bordered`]},G(l.header,u=>{const h=u||this.title;return h?o("div",{class:`${e}-alert-body__title`},h):null}),l.default&&o("div",{class:`${e}-alert-body__content`},l))):null}})}});export{ie as N};
