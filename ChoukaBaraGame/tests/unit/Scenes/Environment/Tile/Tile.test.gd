extends WATTest

var unitUnderTest:Tile
var pawn:Pawn
var area2dInstance:Area2D
var editor_validation_strings:EditorValidationStringConstants = EditorValidationStringConstants.new()

var gameBoard = preload("res://Resources/GameBoards/5x5GameBoard.tres")
var tile:PackedScene  = preload("res://Scenes/Environment/Tile/Tile.tscn")
var pawn_scene:PackedScene  = preload("res://Scenes/Pawn/Pawn.tscn")

func title() -> String:
	return "Tile Unit Tests"

func pre() -> void:
	unitUnderTest = tile.instance()
	watch(unitUnderTest,"pawn_entered")
	watch(unitUnderTest,"pawn_exited")
	pawn = pawn_scene.instance()
	area2dInstance = Area2D.new()

func test_on_ready_should_connect_pawn_entered_signal()->void:
	describe("should connect pawn_entered signal")
	unitUnderTest._ready()
	
	asserts.object_is_connected(unitUnderTest,"area_entered",unitUnderTest,"_on_tile_area_entered","then area_entered signal is connected")

func test_on_ready_should_connect_pawn_exited_signal()->void:
	describe("should connect pawn_exited signal")
	unitUnderTest._ready()
	
	asserts.object_is_connected(unitUnderTest,"area_exited",unitUnderTest,"_on_tile_area_exited","then area_exiited signal is connected")

func test_pawn_enter_is_called_when_area_enter_called_with_pawn_instance() -> void:
	describe("should emit pawn_entered signal when Pawn instance is entering Area2D")
	# Arrange
	# Act
	unitUnderTest._on_tile_area_entered(pawn)
	# Assert
	asserts.is_not_null(unitUnderTest,"tiles is not null")
	asserts.signal_was_emitted(unitUnderTest,"pawn_entered","then pawn_entered signal is emitted")

func test_residingPawns_is_added_with_pawn_when_called_with_pawn_instance() -> void:
	describe("should add pawn to residingPawns Array when Pawn instance is entering Area2D")
	# Arrange
	# Act
	unitUnderTest._on_tile_area_entered(pawn)
	# Assert
	asserts.is_not_null(unitUnderTest.residingPawns,"residingPawns is not null")
	asserts.is_true(unitUnderTest.residingPawns.size() == 1,"then pawn is added")

func test_pawn_enter_is_not_called_when_area_enter_called_with_Area2D_instance() -> void:
	describe("should not emit pawn_entered signal when Pawn instance is entering Area2D")
	# Arrange
	# Act
	unitUnderTest._on_tile_area_entered(area2dInstance)
	# Assert
	asserts.is_not_null(unitUnderTest,"tiles is not null")
	asserts.signal_was_not_emitted(unitUnderTest,"pawn_entered","then pawn_entered signal is not emitted")
	
func test_pawn_exit_is_called_when_area_exit_called_with_pawn_instance() -> void:
	describe("should emit pawn_exited signal when Pawn instance is exiting Area2D")
	# Arrange
	# Act
	unitUnderTest._on_tile_area_exited(pawn)
	# Assert
	asserts.signal_was_emitted(unitUnderTest,"pawn_exited","then pawn_exited signal is emitted")	

func test_pawn_exit_is_not_called_when_area_exit_called_with_Area2D_instance() -> void:
	describe("should not emit pawn_exited signal when Pawn instance is exiting with Area2D")
	# Arrange
	# Act
	unitUnderTest._on_tile_area_exited(area2dInstance)
	# Assert
	asserts.signal_was_not_emitted(unitUnderTest,"pawn_exited","then pawn_exited signal is not emitted")	

func test_residingPawns_is_removed_with_pawn_when_area_exit_called_with_pawn_instance() -> void:
	describe("should remove pawn from residingPawns when pawn_exited signal is exiting with Pawn instance")
	# Arrange
	# Act
	unitUnderTest._on_tile_area_entered(pawn)
	# Assert
	asserts.is_true(unitUnderTest.residingPawns.size() == 1,"then pawn is added")
	
	unitUnderTest._on_tile_area_exited(area2dInstance)
	asserts.is_true(unitUnderTest.residingPawns.size() == 1,"then pawn is not removed")
	
	unitUnderTest._on_tile_area_exited(pawn)
	asserts.is_true(unitUnderTest.residingPawns.size() == 0,"then pawn is removed")

func test_on_exit_tree_the_connected_signals_are_disconnected():
	describe("should disconnect from all signals connected during ready")
	
	unitUnderTest._ready()
	asserts.object_is_connected(unitUnderTest,"area_entered",unitUnderTest,"_on_tile_area_entered","then area_entered signal is connected")
	asserts.object_is_connected(unitUnderTest,"area_exited",unitUnderTest,"_on_tile_area_exited","then area_exiited signal is connected")
	
	unitUnderTest._exit_tree()
	asserts.object_is_not_connected(unitUnderTest,"area_entered",unitUnderTest,"_on_tile_area_entered","then area_entered signal is not connected")
	asserts.object_is_not_connected(unitUnderTest,"area_exited",unitUnderTest,"_on_tile_area_exited","then area_exiited signal is not connected")

func test_validation_message_is_shown_when_game_board_variable_is_set_incorrectly():
	describe("should display validation message when game board is not set")
	var result = unitUnderTest._get_configuration_warning()
	asserts.is_String(result,"then it is a string message")
	asserts.Equality.is_equal(result,editor_validation_strings.ResourceRequiredValidationString.format({"variable":"game_board","type":"GameBoard"}),"then validation error is shown")

func test_validation_message_is_not_shown_when_game_board_variable_is_set_correctly():
	describe("should not display validation message when game board is set")
	unitUnderTest.game_board = gameBoard
	var result = unitUnderTest._get_configuration_warning()
	asserts.is_String(result,"then it is a string message")
	asserts.string_does_not_contain(editor_validation_strings.ResourceRequiredValidationString.format({"variable":"game_board","type":"GameBoard"}),"then validation error is not shown")

func post() -> void:
	unwatch(unitUnderTest,"pawn_entered")
	unwatch(unitUnderTest,"pawn_exited")
	unitUnderTest.queue_free()
	pawn.queue_free()
	area2dInstance.queue_free()