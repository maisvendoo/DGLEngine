utility MExport "Model export for DGLEngine"
(
	local ostream, tabs = ""

	group "Options"
	(
		checkbox cb_CenModel "Centre every model frame"
		checkbox cb_exportTexVerts "Export texture vertices"
	)
	group "Frames"
	(
		spinner sp_start "From:" range:[animationrange.start,animationrange.end,animationrange.start] type:#Integer
		spinner sp_end "To:" range:[animationrange.start,animationrange.end,animationrange.end] type:#Integer
        spinner sp_step "Step:" range:[animationrange.start + 1,animationrange.end,animationrange.start + 1] type:#Integer
        )

	button btn_export "Save As..." width:100
	button btn_about "About" width:100

	-------------------------------------------------------------------------------------
		function ExportTarget obj =
	(
		Format (tabs+"myobj.target = Targetobject()\n") to:ostream
		Format (tabs+"myobj.target.name = \"%\"\n") obj.target.name to:ostream
		Format (tabs+"myobj.target.transform = %\n") obj.target.transform to:ostream
		Format (tabs+"myobj.target.position += createPos\n") to:ostream
	)

        -------------------------------------------------------------------------------------
        function ExportGeneric obj =
	(
		Format (tabs+"%\n") (ClassOf obj) to:ostream

		for prop in GetPropNames obj do
		(
			local propname = prop as String
			local propval  = GetProperty obj prop

			if (ClassOf obj) == Hedra and prop == #vertices then continue

			if propval != undefined then
				Format (tabs+"\t% %\n") propname propval to:ostream
		)
		
		if obj.target != undefined then
			ExportTarget obj

		Format (tabs+"end %\n") (ClassOf obj) to:ostream
	)

	-------------------------------------------------------------------------------------
	function ExportMesh meshObj =
	(
		Format (tabs+"TriMesh()\n") to:ostream
		Format (tabs+"numverts numfaces\n") to:ostream
		Format (tabs+"   %        %\n") meshObj.numverts meshObj.numfaces to:ostream

		-- Write vertices
		if meshObj.numVerts > 0 then
		(

			Format (tabs+"Mesh vertices:\n") to:ostream
			for i = 1 to meshObj.numVerts do
			(
			
			if cb_CenModel.checked then
				(	
				Format (tabs+"\t% % %\n") ((GetVert meshObj i).x - meshObj.Center.x) ((GetVert meshObj i).y - meshObj.Center.y) ((GetVert meshObj i).z - meshObj.Center.z) to:ostream 	
				)
				else
				(
				Format (tabs+"\t% % %\n") ((GetVert meshObj i).x) ((GetVert meshObj i).y) ((GetVert meshObj i).z) to:ostream
				)
			)
			Format (tabs+"end vertices\n") to:ostream
		)


		-- Write faces
		if meshObj.numFaces > 0 then
		(
			Format (tabs+"Mesh faces:\n") to:ostream
			for i = 1 to meshObj.numFaces do
                        (
				Format (tabs+"\t% % %\n") ((GetFace meshObj i).x as Integer) ((GetFace meshObj i).y as integer) ((GetFace meshObj i).z as Integer) to:ostream
                        )
			Format (tabs+"end faces\n") to:ostream
		)

		

		
		Format (tabs+"end mesh\n") to:ostream
	)

	-------------------------------------------------------------------------------------
	function ExportTexVertices MeshObj =
	(
                Format (tabs+"numtverts numtvfaces\n") to:ostream
		Format (tabs+"   %        %\n") meshObj.numTVerts meshObj.numfaces to:ostream		

		-- Write texture vertices
		if MeshObj.numTVerts > 0 then
		(
  		        Format (tabs+"Texture vertices:\n") to:ostream

			for i = 1 to meshObj.NumTVerts do
			(
				Format (tabs+"\t% % %\n") (GetTVert meshObj i).x (GetTVert meshObj i).y (GetTVert meshObj i).z to:ostream
			)
			Format (tabs + "end texture vertices\n") to:ostream
		)
		
		-- Write texture faces
		if meshObj.numfaces > 0 then
		(
			Format (tabs+"Texture faces:\n") to:ostream

			for i = 1 to meshObj.numfaces do
			(
				Format (tabs+"\t% % %\n") ((GetTVFace meshObj i).x as Integer) ((GetTVFace meshObj i).y as Integer) ((GetTVFace meshObj i).z as Integer) to:ostream
			)
			Format (tabs + "end texture faces\n") to:ostream
		)
		
	)
	-------------------------------------------------------------------------------------
	function ExportNode node =
	(
		Format "New object\n" to:ostream
		if SuperClassOf node == GeometryClass and ClassOf node == Editable_mesh then
			ExportMesh node
		else if (not (ClassOf node == Targetobject and node.isTarget)) then
			ExportGeneric node
		else
			return false

		return true
	)

	-------------------------------------------------------------------------------------
	function ExportGMS =
	(
			for node in selection do
				ExportNode node
			
	)

	-------------------------------------------------------------------------------------
	function GetSaveFileStream =
	(
		fname = GetSaveFileName types:"DGLEngine Models Files (*.dmd)|*.dmd|All Files(*.*)|*.*|"
		if fname == undefined then
			return undefined

		ostream = CreateFile fname
		if ostream == undefined then
		(
			MessageBox "Couldn't open file for writing !"
			return undefined
		)

		return ostream
	)

	-------------------------------------------------------------------------------------
	on btn_about pressed do
	(
		MessageBox "Meshes Export for DRON's OpenGl Engine V 1.1" title:"About"
	) -------------------------------------------------------------------------------------
	on btn_export pressed do
	(
		ostream = GetSaveFileStream()
		if ostream != undefined then
		(
			i = sp_start.value
			while i <= sp_end.value do
			(
				slidertime = i
				ExportGMS()
				i += sp_step.value
			)
			
			if cb_exportTexVerts.checked then
			(
				for node in selection do
				(
		                  if SuperClassOf node == GeometryClass and ClassOf node == Editable_mesh then
					(
					Format "New Texture:\n" to:ostream
					ExportTexVertices node
					Format "end of texture\n"	to:ostream
					)
				)
			)

		        Format "end of file" to:ostream 
			Close ostream
		)
	)
	--------------------------------------------------------------------------------------
	on sp_start changed value do
	(
		slidertime = sp_start.value
	)

) -- End MEGExport


