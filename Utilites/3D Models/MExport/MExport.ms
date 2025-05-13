--(c)DeeProSoft 2008 (www.deeprosoft.com)
--Script author: DRON http://dronprogs.mirgames.ru
utility MExport "DMD Scene Exporter"
(
	local tabs = "", counter = 0,
	scenefname = "", scenedir = "",
	scenestream,
	--For interract with rollouts
	isnorm_checked, isCennScale_checked,
	isanim, anim_b, anim_e, anim_s
	
	label whtexp "Select what to export:"	
	radiobuttons rb_ExScene labels:#("Entire scene objects","Selected objects only") default:1
	
	label note1	 "Please note, that script works"
	label note2  "only with \"Editable Mesh\"'s."
	
	button btn_export "Export" width:100
	button btn_about "About" width:100
	-------------------------------------------------------------------------------------
	function GetSaveDMDStream =
	(
		fname = GetSaveFileName types:"DMD Mesh Files (*.dmd)|*.dmd|All Files(*.*)|*.*|"
		if fname == undefined then
			return undefined

		return fname
	)
	-------------------------------------------------------------------------------------
	function GetSaveSceneStream =
	(
		fname = GetSaveFileName types:"DSC Scene Files (*.dsc)|*.dsc|All Files(*.*)|*.*|"
		if fname == undefined then
			return undefined

		return fname
	)
	-------------------------------------------------------------------------------------
	function GetFName fname = 
	(
		curname = ""
		for i = 1 to fname.count do
		if fname[i]=="\\" then curname = "" else curname=curname+fname[i]
		
		return curname

	)
	-------------------------------------------------------------------------------------
	function GetDir fname =
	(
		dirname = ""
		temp = ""
		
		for i = 1 to fname.count do
		(
			temp = temp + fname[i]
			if fname[i]=="\\" then 
				(
				 	dirname = dirname + temp
					temp = ""
				)
		)
		
		return dirname
	)
	-------------------------------------------------------------------------------------
	function write_obj_to_scene name x y z scale =
	(
		if scenestream!=undefined then
		(
		Format (tabs+"Entity()\n") to:scenestream
		Format (tabs+"uid\n") to:scenestream
		Format (tabs+"%\n") counter to:scenestream
		Format (tabs+"name\n") to:scenestream
		Format (tabs+name+"\n") to:scenestream
		Format (tabs+"pos\n") to:scenestream
		Format (tabs+"% % %\n") x y z to:scenestream
		Format (tabs+"scale\n") to:scenestream
		Format (tabs+"%\n") scale to:scenestream
		Format (tabs+"end entity\n\n") to:scenestream
		)
	)
	-------------------------------------------------------------------------------------
	function abs_max val1 val2 =
	(
		t1 = abs(val1)
		t2 = abs(val2)
		if t1>t2 then return t1 else return t2
	)
	-------------------------------------------------------------------------------------
	function ExportMesh meshObj =
	(
	
	 if meshObj.numFaces > 0 and meshObj.numVerts > 0 then
	 (
	
		if rb_ExScene.state == 1 then
		name = scenedir+meshObj.name+".dmd"
		else name = GetSaveDMDStream()
		
		ostream = CreateFile name 

		if ostream == undefined then
		(
			MessageBox "Couldn't open file for writing !"
			return undefined
		)
		
		Format (tabs+"DMD 2.0\n") to:ostream
		Format (tabs+"New object\n") to:ostream
		
		--Calculate center ans scale factor
		fscale = 1.0; fcx = 0.0; fcy = 0.0; fcz = 0.0
		if (rb_ExScene.state == 2 and isCennScale_checked) or rb_ExScene.state == 1 then	
		(
			fcx = meshObj.Center.x
			fcy = meshObj.Center.y
			fcz = meshObj.Center.z
			
			maxvertex = 0.0
			
			if meshObj.numVerts > 0 then
			(
			for i = 1 to meshObj.numVerts do
			(
				maxvertex = abs_max ((GetVert meshObj i).x - fcx) maxvertex 
				maxvertex = abs_max ((GetVert meshObj i).y - fcy) maxvertex 
				maxvertex = abs_max ((GetVert meshObj i).z - fcz) maxvertex 
			)
			fscale = 1./maxvertex --TODO: Calculation of scale for current frame might not be correct for animated models cause some frames could have bigger BBoxes
			)
		)

		--Write object info to scene
		if rb_ExScene.state == 1 then
		write_obj_to_scene meshObj.name fcx fcy fcz (1./fscale)

		--For frame animation cycle
		if rb_ExScene.state == 2 and isanim then
			exp_fr = anim_b 
		else
		(
			exp_fr = 0
			anim_e = 0
			anim_s = 1
		)
		
		
		while exp_fr <= anim_e do
		(
		slidertime = exp_fr

		Format (tabs+"TriMesh()\n") to:ostream
		Format (tabs+"numverts numfaces\n") to:ostream
		Format (tabs+"   %        %\n") meshObj.numverts meshObj.numfaces to:ostream

		-- Write vertices
		if meshObj.numVerts > 0 then
		(

			Format (tabs+"Mesh vertices:\n") to:ostream
			for i = 1 to meshObj.numVerts do
				Format (tabs+"\t% % %\n") (((GetVert meshObj i).x - fcx)*fscale) (((GetVert meshObj i).y - fcy)*fscale) (((GetVert meshObj i).z - fcz)*fscale) to:ostream
			Format (tabs+"end vertices\n") to:ostream
		)


		-- Write faces
		if meshObj.numFaces > 0 then
		(
			Format (tabs+"Mesh faces:\n") to:ostream
			for i = 1 to meshObj.numFaces do
						Format (tabs+"\t% % %\n") ((GetFace meshObj i).x as Integer) ((GetFace meshObj i).y as integer) ((GetFace meshObj i).z as Integer) to:ostream
 			Format (tabs+"end faces\n") to:ostream
		)

		if (rb_ExScene.state == 2 and isnorm_checked) or rb_ExScene.state == 1 then	
		-- Write smoothing normals
		if meshObj.numVerts > 0 then
		(
			Format (tabs+"Smooth normals:\n") to:ostream
			for i = 1 to meshObj.numVerts do
				Format (tabs+"\t% % %\n") (GetNormal meshObj i).x (GetNormal meshObj i).y (GetNormal meshObj i).z to:ostream 	
			Format (tabs+"end smooth normals\n") to:ostream
		)

		
		Format (tabs+"end mesh\n") to:ostream
		
		exp_fr += anim_s
		
		)


		--Write material
		if meshObj.material != undefined then
		(
		Format "Material:\n" to:ostream

		--Write colors
		Format "diffuse color\n" to:ostream
		try
		Format (tabs+"\t% % %\n") meshObj.material.Diffuse.r meshObj.material.Diffuse.g meshObj.material.Diffuse.b to:ostream 	
		catch Format (tabs+"\t"+"None\n") to:ostream
		Format "ambient color\n" to:ostream
		try
		Format (tabs+"\t% % %\n") meshObj.material.Ambient.r meshObj.material.Ambient.g meshObj.material.Ambient.b to:ostream 	
		catch Format (tabs+"\t"+"None\n") to:ostream
		Format "specular color\n" to:ostream
		try
		Format (tabs+"\t% % %\n") meshObj.material.Specular.r meshObj.material.Specular.g meshObj.material.Specular.b to:ostream 	
		catch Format (tabs+"\t"+"None\n") to:ostream
		Format "glossiness\n" to:ostream
		try
		Format (tabs+"\t"+meshObj.material.glossiness as string+"\n") to:ostream 	
		catch Format (tabs+"\t"+"None\n") to:ostream
		Format "opacity\n" to:ostream
		try
		Format (tabs+"\t"+meshObj.material.opacity as string+"\n") to:ostream 	
		catch Format (tabs+"\t"+"None\n") to:ostream

		--Extract maps
		Format "diffuse map\n" to:ostream			
		try
		Format (tabs+GetFName(meshObj.material.diffuseMap.filename)+"\n") to:ostream
		catch Format (tabs+"None\n") to:ostream

		Format "bump map\n" to:ostream			
		try
		Format (tabs+GetFName(meshObj.material.bumpMap.filename)+"\n") to:ostream
		catch Format (tabs+"None\n") to:ostream

		Format "specular map\n" to:ostream			
		try
		Format (tabs+GetFName(meshObj.material.specularMap.filename)+"\n") to:ostream
		catch Format (tabs+"None\n") to:ostream


		Format "end material\n" to:ostream
		)
		
		--Write texture if presented
			if meshObj.numTVerts > 0 then
			(					

					Format "New Texture:\n" to:ostream

							Format (tabs+"numtverts numtvfaces\n") to:ostream
							Format (tabs+"   %        %\n") meshObj.numTVerts meshObj.numfaces to:ostream		

							-- Write texture vertices
							if MeshObj.numTVerts > 0 then
							(
  		    	 				Format (tabs+"Texture vertices:\n") to:ostream

								for i = 1 to meshObj.NumTVerts do
								Format (tabs+"\t% % %\n") (GetTVert meshObj i).x (GetTVert meshObj i).y (GetTVert meshObj i).z to:ostream
								Format (tabs + "end texture vertices\n") to:ostream
							)
		
							-- Write texture faces
							if meshObj.numfaces > 0 then
							(
								Format (tabs+"Texture faces:\n") to:ostream

								for i = 1 to meshObj.numfaces do
								Format (tabs+"\t% % %\n") ((GetTVFace meshObj i).x as Integer) ((GetTVFace meshObj i).y as Integer) ((GetTVFace meshObj i).z as Integer) to:ostream
								Format (tabs + "end texture faces\n") to:ostream
							)
	
					Format "end of texture\n"	to:ostream
					
			)

		    Format "end of file" to:ostream 
			Close ostream
	  )
			counter += 1

	)

	-------------------------------------------------------------------------------------
	function RecursiveExportNode node =
	(
		if (ExportMesh node) == false then
			return false

		-- Recurse children before writing this node
		for child in node.children do
			RecursiveExportNode child
			
	)
	-------------------------------------------------------------------------------------
	rollout roll_about "About" width:200	
	(
		label abl_1 "DMD Mesh and Scene Exporter."
		label abl_2 "V 2.0"
		label abl_3 "For DGLEngine and DeeProEngine."
		label abl_4 "Author: DRON (dronprogs.mirgames.ru)"	
		label abl_5 "(c)DeeProSoft 2008"
		label abl_6 "www.deeprosoft.com"
		button btn_ok "Ok" width:50
		on btn_ok pressed do
 			DestroyDialog roll_about
	)
	
	on btn_about pressed do 
		createDialog roll_about	modal:true;
	-------------------------------------------------------------------------------------
	rollout roll_sce "Scene Export"
	(
		label lexptodir "Exporting scene to directory."

		progressbar prog color:blue
		button btn_dir "Save As..." width:100
		
		on btn_dir pressed do
		(
		
			scenefname = GetSaveSceneStream()
			if scenefname != undefined then
			(
			counter = 0
			skipped = 0
			btn_dir.visible = false
			scenedir = GetDir scenefname
			
			scenestream = CreateFile scenefname 
			if scenestream == undefined then
			(
			MessageBox "Couldn't open file for writing !"
			return undefined
			)
		
			Format (tabs+"DSC 1.0\n") to:scenestream
			Format (tabs+"obj_count\n") to:scenestream
			obj_count = 0
			i = 0
			for node in rootnode.children do
			(
				if SuperClassOf node == GeometryClass and ClassOf node == Editable_mesh then
				obj_count+=1 --TODO: Current node can also have children so obj_count may not be correct if children recurse is not presented
				i += 1
			)
			Format (tabs+"\t%\n") obj_count to:scenestream

			i = 0
			for node in rootnode.children do
			(
			prog.value = 100.*i/rootnode.children.count 
			if SuperClassOf node == GeometryClass and ClassOf node == Editable_mesh then
			RecursiveExportNode node else skipped = skipped + 1
			i += 1
			)

			Format (tabs+"end of file") to:scenestream
			Close scenestream
			
			prog.value = 0
			btn_dir.visible = true
			text = "There are " + skipped as string + " skipped objects, because they are not \"Editable Mesh\"s!"
			if skipped != 0 then MessageBox text Title:"Attention"
			DestroyDialog roll_sce
			)
		)

	)
	-------------------------------------------------------------------------------------
	rollout roll_sel_m "Selected Mesh"
	(
		label lexpmesh "Exporting currently selected mesh."
		
		checkbox cb_CenScModel "Centre and scale mesh"
		checkbox cb_ExpNorm "Export smooth normals"
	
		checkbox cb_DoAnimation "Export animation"
		
		label lframes "Frames:"
			spinner sp_start "From:" range:[animationrange.start,animationrange.end,animationrange.start] type:#Integer
			spinner sp_end "To:" range:[animationrange.start,animationrange.end,animationrange.end] type:#Integer
       		spinner sp_step "Step:" range:[animationrange.start + 1,animationrange.end,animationrange.start + 1] type:#Integer
		
		button btn_save "Save As..." width:100

		on roll_sel_m open do
		(
			cb_CenScModel.checked = true
			cb_ExpNorm.checked = true
			sp_start.enabled = false
			sp_end.enabled = false
			sp_step.enabled = false
			lframes.enabled = false
		)
		
		on cb_DoAnimation changed state do
		(
			if cb_DoAnimation.checked then
			(
			sp_start.enabled = true
			sp_end.enabled = true
			sp_step.enabled = true
			lframes.enabled = true
			)
			else
			(
			sp_start.enabled = false
			sp_end.enabled = false
			sp_step.enabled = false		
			lframes.enabled = false
			)
		)
		
		on btn_save pressed do
		(	
			isCennScale_checked = cb_CenScModel.checked
			isnorm_checked = cb_ExpNorm.checked
			
			isanim = cb_DoAnimation.checked
			anim_b = sp_start.value
			anim_e = sp_end.value
			anim_s = sp_step.value
			
			for node in selection do
				ExportMesh node
			DestroyDialog roll_sel_m
		)
		
	)
	-------------------------------------------------------------------------------------
	on btn_export pressed do
	(
		
		case rb_ExScene.state of
		(
			1: createDialog roll_sce	modal:true;
			2: createDialog roll_sel_m  modal:true;
		)
		
	)
) 


