## Suite do ScoreSingleton: saldo acumula sem teto, gasto funciona, sem odometro.
extends GdUnitTestSuite

const __source := "res://Source/Core/ScoreSingleton/ScorePoint.gd"


func test_score_accumulates_and_spends() -> void:
	# Arrange — deltas, nunca absolutos: outros testes sujam o singleton
	var saved_max: int = ScoreSingleton.max_amount
	var saved_current: int = ScoreSingleton.current_amount
	var point := auto_free(ScorePoint.new()) as ScorePoint

	# Act — ganha, ganha, gasta
	point.score(10)
	point.score(5)
	ScoreSingleton.decrease(4)

	# Assert — saldo andou +11, teto intacto (sem odometro: max nao anda junto)
	assert_int(ScoreSingleton.current_amount).is_equal(saved_current + 11)
	assert_int(ScoreSingleton.max_amount).is_equal(saved_max)

	# Cleanup — devolve o singleton como encontrou
	ScoreSingleton.max_amount = saved_max
	ScoreSingleton.current_amount = saved_current
