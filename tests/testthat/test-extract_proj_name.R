skip_if_offline()

test_that("extracts qualified", {
  qual <- extract_proj_name(qualified_path)

  expect_type(qual, 'list')
  expect_named(qual, c('project_name', 'project_code'))
  expect_equal(
    qual$project_name,
    "Assessing the effects of aquaculture operations on the distribution and abundance of pelagic fishes and large predators in the Bay of Fundy. ##### Évaluation des effets des opérations aquaculture sur la distribution et l'abondance des poissons pélagiques et des grands prédateurs dans la baie de Fundy.")
  expect_equal(
    qual$project_code,
    "PBSM"
  )
})

test_that("extracts unqualified", {
  unqual <- extract_proj_name(unqualified_path)

  expect_type(unqual, 'list')
  expect_named(unqual, c('project_name', 'project_code'))
  expect_equal(
    unqual$project_name,
    "Assessing the effects of aquaculture operations on the distribution and abundance of pelagic fishes and large predators in the Bay of Fundy. ##### Évaluation des effets des opérations aquaculture sur la distribution et l'abondance des poissons pélagiques et des grands prédateurs dans la baie de Fundy.")
  expect_equal(
    unqual$project_code,
    "PBSM"
  )
})

test_that("extracts matched", {
  matched <- extract_proj_name(matched_path)

  expect_type(matched, 'list')
  expect_named(matched, c('project_name', 'project_code'))
  expect_equal(
    matched$project_name,
    "Assessing the effects of aquaculture operations on the distribution and abundance of pelagic fishes and large predators in the Bay of Fundy. ##### Évaluation des effets des opérations aquaculture sur la distribution et l'abondance des poissons pélagiques et des grands prédateurs dans la baie de Fundy.")
  expect_equal(
    matched$project_code,
    "PBSM"
  )
})

test_that("is network agnostic", {
  write.csv(
    data.frame(collectioncode = 'ACT.TAILWINDS'),
    file.path(td, 'testfile.csv')
  )

  act <- extract_proj_name(file.path(td, 'testfile.csv'))

  expect_type(act, 'list')
  expect_named(act, c('project_name', 'project_code'))
  expect_equal(
    act$project_name,
    "TailWinds: Team for Assessing Impacts to Living resources from offshore WIND turbineS")
  expect_equal(
    act$project_code,
    "TAILWINDS"
  )


  write.csv(
    data.frame(collectioncode = 'TAILWINDS'),
    file.path(td, 'testfile2.csv')
  )

  act2 <- extract_proj_name(file.path(td, 'testfile.csv'))

  expect_type(act2, 'list')
  expect_named(act2, c('project_name', 'project_code'))
  expect_equal(
    act2$project_name,
    "TailWinds: Team for Assessing Impacts to Living resources from offshore WIND turbineS")
  expect_equal(
    act2$project_code,
    "TAILWINDS"
  )
})
