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


func test_trauma_for_curve() -> void:
	# Arrange — função pura: sem nós, sem autoload, sem frames
	# Act + Assert — zero dá zero, 10 dá soluço, 100 satura em 1.0
	assert_float(ScorePoint.trauma_for(0)).is_equal_approx(0.0, 0.0001)
	assert_float(ScorePoint.trauma_for(10)).is_equal_approx(0.3162, 0.001)
	assert_float(ScorePoint.trauma_for(100)).is_equal_approx(1.0, 0.0001)


func test_trauma_override_wins() -> void:
	# Arrange
	var point := ScorePoint.new()
	point.trauma_override = 0.9

	# Act + Assert — override >= 0 ignora a curva
	assert_float(ScorePoint.trauma_for(10)).is_equal_approx(0.3162, 0.001)
	var received: Array = []
	point.scored.connect(func(points: int, trauma: float) -> void: received.append([points, trauma]))
	point.score(10)

	# Assert — emitido com o override, não com a curva
	assert_int(received.size()).is_equal(1)
	assert_float(received[0][1]).is_equal_approx(0.9, 0.0001)
	auto_free(point)
