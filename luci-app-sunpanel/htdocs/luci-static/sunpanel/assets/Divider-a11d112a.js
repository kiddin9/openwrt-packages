import{m as p,aj as c,p as n,K as t,f,q as u,z as v,cO as b,y as x,B as C,g as d,ao as $}from"./index-7e19b821.js";const w=p("divider",`
 position: relative;
 display: flex;
 width: 100%;
 box-sizing: border-box;
 font-size: 16px;
 color: var(--n-text-color);
 transition:
 color .3s var(--n-bezier),
 background-color .3s var(--n-bezier);
`,[c("vertical",`
 margin-top: 24px;
 margin-bottom: 24px;
 `,[c("no-title",`
 display: flex;
 align-items: center;
 `)]),n("title",`
 display: flex;
 align-items: center;
 margin-left: 12px;
 margin-right: 12px;
 white-space: nowrap;
 font-weight: var(--n-font-weight);
 `),t("title-position-left",[n("line",[t("left",{width:"28px"})])]),t("title-position-right",[n("line",[t("right",{width:"28px"})])]),t("dashed",[n("line",`
 background-color: #0000;
 height: 0px;
 width: 100%;
 border-style: dashed;
 border-width: 1px 0 0;
 `)]),t("vertical",`
 display: inline-block;
 height: 1em;
 margin: 0 8px;
 vertical-align: middle;
 width: 1px;
 `),n("line",`
 border: none;
 transition: background-color .3s var(--n-bezier), border-color .3s var(--n-bezier);
 height: 1px;
 width: 100%;
 margin: 0;
 `),c("dashed",[n("line",{backgroundColor:"var(--n-color)"})]),t("dashed",[n("line",{borderColor:"var(--n-color)"})]),t("vertical",{backgroundColor:"var(--n-color)"})]),_=Object.assign(Object.assign({},v.props),{titlePlacement:{type:String,default:"center"},dashed:Boolean,vertical:Boolean}),z=f({name:"Divider",props:_,setup(r){const{mergedClsPrefixRef:o,inlineThemeDisabled:l}=u(r),s=v("Divider","-divider",w,b,r,o),a=x(()=>{const{common:{cubicBezierEaseInOut:e},self:{color:h,textColor:g,fontWeight:m}}=s.value;return{"--n-bezier":e,"--n-color":h,"--n-text-color":g,"--n-font-weight":m}}),i=l?C("divider",void 0,a,r):void 0;return{mergedClsPrefix:o,cssVars:l?void 0:a,themeClass:i==null?void 0:i.themeClass,onRender:i==null?void 0:i.onRender}},render(){var r;const{$slots:o,titlePlacement:l,vertical:s,dashed:a,cssVars:i,mergedClsPrefix:e}=this;return(r=this.onRender)===null||r===void 0||r.call(this),d("div",{role:"separator",class:[`${e}-divider`,this.themeClass,{[`${e}-divider--vertical`]:s,[`${e}-divider--no-title`]:!o.default,[`${e}-divider--dashed`]:a,[`${e}-divider--title-position-${l}`]:o.default&&l}],style:i},s?null:d("div",{class:`${e}-divider__line ${e}-divider__line--left`}),!s&&o.default?d($,null,d("div",{class:`${e}-divider__title`},this.$slots),d("div",{class:`${e}-divider__line ${e}-divider__line--right`})):null)}});export{z as N};
