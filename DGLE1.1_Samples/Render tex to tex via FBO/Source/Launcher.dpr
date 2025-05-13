program Launcher;

uses
  DGLEngine_header in '..\..\..\System\DGLEngine_header.pas';

{$R Ico.res}

var Floor, Blood, res_tex : cardinal;

procedure EngineInit;
begin
 Floor:=LoadTextureFromFile('..\..\Samples\Beginner\Draw texture to texture\Back.jpg');
 Blood:=LoadTextureFromFile('..\..\Samples\Beginner\Draw texture to texture\Blood.bmp',TEXDETAIL_BEST,TRANSCOLOR_AQUA);
 if IsFBOSupported then
 begin
 res_tex:=CreateTextureToRenderIn(GetTextureInfo(Floor).Width,GetTextureInfo(Floor).Height);
 DrawTextureToTexture(Floor,res_tex,0,0);
 end;
end;

procedure Draw;
begin
Begin2D;

 if IsFBOSupported then
 DrawTexture2D_Simple(res_tex,0,0,800,600)
 else
 DrawTexture2D_Simple(Floor,0,0,800,600);

End2D;
end;

procedure Process;
begin

 if random(25)=12 then
 if IsFBOSupported then
 begin
 //При рендере в FBO албфа текстуры берется та, которая указана при щагрузке текстуры
 //Размер ToTexture должен быть равен размеру TexTarget
 RenderTexToTexFBO(Floor,TEX_BLANK,res_tex,0,0);
 RenderTexToTexFBO(res_tex,Blood,Floor,random(512),random(512));
 end else
 DrawTextureToTextureTransparentColor(Blood,Floor,random(512),random(512),TRANSCOLOR_AQUA);

 if IsKeyPressed(Key_Escape) then
 QuitEngine;

end;


begin

 if LoadDGLEngineDLL('..\..\System\DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@EngineInit);

  SetEngineInitParametrs(800,600,32,85,false,false,false);

  StartEngine;

  FreeDGLEngineDLL;
 end;

end.
