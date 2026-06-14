function build_catss_physical_trade_study
%BUILD_CATSS_PHYSICAL_TRADE_STUDY Build CATSS physical architecture variants.
%
% Creates a reusable System Composer trade-study baseline with:
%   - a shared physical interface dictionary
%   - a shared trade-study profile and scoring metadata
%   - three physical architecture variants
%   - one allocation set per variant from CATSS_Functional
%   - requirement implementation links to CATSS system requirements
%   - a comparison report with weighted trade results

clc;

studyDir = fileparts(mfilename("fullpath"));
archDir = fileparts(studyDir);
rootDir = fileparts(archDir);
analysisDir = fullfile(rootDir, "analysis");
allocDir = fullfile(studyDir, "allocations");
reqDir = fullfile(rootDir, "requirements");
funcModelFile = fullfile(archDir, "CATSS_Functional.slx");
funcModelName = "CATSS_Functional";
profileName = "CATSS_PhysicalTradeProfile";
profileFile = fullfile(studyDir, profileName + ".xml");
dictFile = fullfile(studyDir, "CATSS_PhysicalInterfaces.sldd");
reportFile = fullfile(analysisDir, "CATSS_PhysicalArchitectureTradeStudy.md");
reqFile = fullfile(reqDir, "CATSS_SystemRequirements.slreqx");

if ~isfolder(allocDir)
    mkdir(allocDir);
end
if ~isfolder(analysisDir)
    mkdir(analysisDir);
end

cleanupGeneratedFiles(studyDir, allocDir, analysisDir, profileFile, dictFile, reportFile);

bdclose("all");
slreq.clear;
Simulink.data.dictionary.closeAll("-discard");
systemcomposer.profile.Profile.closeAll();
systemcomposer.allocation.AllocationSet.closeAll();

variants = defineVariants();
criteria = defineCriteria();

createTradeProfile(profileName, profileFile, studyDir);
createPhysicalInterfaceDictionary(dictFile);
systemcomposer.profile.Profile.closeAll();
Simulink.data.dictionary.closeAll("-discard");

funcModel = systemcomposer.openModel(char(funcModelFile));
funcArch = funcModel.Architecture;
srSet = slreq.load(char(reqFile));

for idx = 1:numel(variants)
    buildVariantModel(variants(idx), studyDir, dictFile, profileName, criteria);
    createVariantAllocation(variants(idx), allocDir, funcModelName, funcArch);
    createRequirementLinks(variants(idx), reqFile, srSet);
end

slreq.saveAll();

writeTradeStudyReport(reportFile, variants, criteria);

fprintf("Built physical trade study artifacts in %s\n", studyDir);
fprintf("Comparison report written to %s\n", reportFile);
end

function cleanupGeneratedFiles(studyDir, allocDir, analysisDir, profileFile, dictFile, reportFile)
generated = {
    profileFile
    dictFile
    reportFile
    fullfile(studyDir, "CATSS_Physical_MonolithicCoreHabitat.slx")
    fullfile(studyDir, "CATSS_Physical_MonolithicCoreHabitat~mdl.slmx")
    fullfile(studyDir, "CATSS_Physical_DistributedHabitatCluster.slx")
    fullfile(studyDir, "CATSS_Physical_DistributedHabitatCluster~mdl.slmx")
    fullfile(studyDir, "CATSS_Physical_ServiceCorePods.slx")
    fullfile(studyDir, "CATSS_Physical_ServiceCorePods~mdl.slmx")
    fullfile(allocDir, "CATSS_Functional_to_MonolithicCoreHabitat.mldatx")
    fullfile(allocDir, "CATSS_Functional_to_DistributedHabitatCluster.mldatx")
    fullfile(allocDir, "CATSS_Functional_to_ServiceCorePods.mldatx")
    };

for idx = 1:numel(generated)
    if isfile(generated{idx})
        delete(generated{idx});
    end
end

if ~isfolder(analysisDir)
    mkdir(analysisDir);
end
end

function criteria = defineCriteria()
criteria.primaryWeights = struct( ...
    "Affordability", 0.28, ...
    "ModularGrowthEfficiency", 0.24, ...
    "ResupplySustainability", 0.16, ...
    "WelfareSupport", 0.12, ...
    "SafetySurvivability", 0.10, ...
    "AutonomySupport", 0.10);

criteria.alternateWeights = struct( ...
    "Affordability", 0.05, ...
    "ModularGrowthEfficiency", 0.08, ...
    "ResupplySustainability", 0.10, ...
    "WelfareSupport", 0.33, ...
    "SafetySurvivability", 0.29, ...
    "AutonomySupport", 0.15);

criteria.rules = [
    "Use a 1-5 ordinal scale for qualitative criteria, where 5 is best."
    "Use rough quantitative estimates for mass, volume, and power as relative engineering values for ranking only."
    "Every criterion score cites at least one traced requirement, allocated function, or modeled architectural feature."
    ];

criteria.sections = struct( ...
    "LifeSupportAutonomy", {{ ...
        'SR-001','SR-002','SR-003','SR-004','SR-005','SR-006','SR-007','SR-008','SR-009', ...
        'SR-019','SR-020','SR-021','SR-022','SR-023','SR-024','SR-025','SR-026','SR-027', ...
        'SR-028','SR-029','SR-030','SR-031','SR-032'}}, ...
    "SafetySurvivability", {{'SR-033','SR-034','SR-035','SR-036','SR-037'}}, ...
    "ArchitectureCostInterfaces", {{'SR-038','SR-039','SR-040','SR-041','SR-042'}}, ...
    "WelfareDrivers", {{'SR-010','SR-011','SR-012','SR-013','SR-014','SR-015','SR-016','SR-017','SR-018'}});
end

function variants = defineVariants()
variants = repmat(struct, 1, 3);

variants(1).Label = "Monolithic Core Habitat";
variants(1).ModelName = "CATSS_Physical_MonolithicCoreHabitat";
variants(1).File = "CATSS_Physical_MonolithicCoreHabitat.slx";
variants(1).ShortName = "Monolithic";
variants(1).AllocationFile = "CATSS_Functional_to_MonolithicCoreHabitat.mldatx";
variants(1).CoreConcept = "Single primary habitat bus integrates life support and caretaking systems with limited external growth ports.";
variants(1).Strengths = "Lowest integration overhead, compact crew and cat operations, straightforward safe-haven consolidation.";
variants(1).Risks = "Poor growth efficiency, larger single-module launch pressure, concentrated single-point maintenance burden.";
variants(1).PressurePoints = "SR-038, SR-039, SR-040, SR-042";
variants(1).RecommendationNote = "Competitive when minimizing near-term development cost and centralizing safety systems outweighs expansion flexibility.";
variants(1).Properties = struct( ...
    "MassEstimate", 4.6, ...
    "VolumeEstimate", 4.7, ...
    "PowerEstimate", 4.4, ...
    "RecurringOpsComplexity", 2.0, ...
    "ModularityScore", 2.0, ...
    "ResupplyBurden", 3.0, ...
    "WelfareSupportScore", 4.0, ...
    "SafetyRobustnessScore", 4.4, ...
    "AutonomyEnablementScore", 4.2, ...
    "CostRisk", 3.2, ...
    "AffordabilityScore", 3.6, ...
    "ModularGrowthEfficiencyScore", 2.1, ...
    "ResupplySustainabilityScore", 3.2, ...
    "WelfareTradeScore", 4.1, ...
    "SafetyTradeScore", 4.5, ...
    "AutonomyTradeScore", 4.1);
variants(1).ScoreRationale = struct( ...
    "Affordability", "SR-039 and SR-040 penalize the large integrated launch package, but shared systems lower near-term module count.", ...
    "ModularGrowthEfficiency", "SR-038 is weak because expansion depends on attaching support elements to a tightly integrated bus.", ...
    "ResupplySustainability", "SR-006, SR-019, SR-028, and SR-042 are helped by centralized stores but mass concentration raises logistics sensitivity.", ...
    "WelfareSupport", "SR-010, SR-011, SR-014, and SR-015 benefit from one large contiguous habitat with integrated refuge zoning.", ...
    "SafetySurvivability", "SR-033, SR-035, and SR-037 score well because safe haven, emergency power, and suppression systems are concentrated.", ...
    "AutonomySupport", "SustainLifeSupport and OperateStation allocate cleanly to integrated automation and ECLSS bays supporting SR-030 and SR-031.");
variants(1).Components = buildComponentData( ...
    ["MonolithicHabitatBus","IntegratedECLSSBay","OperationsAndLogisticsDeck","SafetyAssuranceShell","ColonyCareSuite"], ...
    ["ProvideHabitat","SustainLifeSupport","OperateStation","EnsureSafety","CareForColony"], ...
    { ...
        {'HabitatShell','RefugePartitions','SensoryLightingGrid','PerchSpine'}, ...
        {'AtmosphereProcessor','WaterRecoveryRack','ThermalControlLoop','WasteProcessingRack'}, ...
        {'AutonomyComputer','CommunicationsSuite','ConsumablesStore','ExpansionVestibule'}, ...
        {'FaultManagementUnit','FireSuppressionLoop','EmergencyBattery','RadiationStormShelter'}, ...
        {'FeedingWateringLine','LitterServiceRack','HealthMonitoringArray','VetQuarantineBay'}}, ...
    { ...
        {'SR-010','SR-011','SR-012','SR-013','SR-014','SR-015','SR-016','SR-017','SR-018'}, ...
        {'SR-001','SR-002','SR-003','SR-004','SR-005','SR-006','SR-007','SR-008','SR-009','SR-020','SR-024','SR-028','SR-029'}, ...
        {'SR-019','SR-028','SR-029','SR-030','SR-031','SR-032','SR-038','SR-039','SR-040','SR-041','SR-042'}, ...
        {'SR-033','SR-034','SR-035','SR-036','SR-037'}, ...
        {'SR-019','SR-021','SR-022','SR-023','SR-025','SR-026','SR-027','SR-030'}});
variants(1).Allocations = { ...
    'SustainLifeSupport','IntegratedECLSSBay'; ...
    'ProvideHabitat','MonolithicHabitatBus'; ...
    'OperateStation','OperationsAndLogisticsDeck'; ...
    'EnsureSafety','SafetyAssuranceShell'; ...
    'CareForColony','ColonyCareSuite'; ...
    'EnableModularGrowth','OperationsAndLogisticsDeck'};
variants(1).Connections = buildConnections( ...
    { ...
    'OperationsAndLogisticsDeck','CommandsToHabitat','MonolithicHabitatBus','CommandsFromOps','CommandTelemetryIF'; ...
    'OperationsAndLogisticsDeck','CommandsToLifeSupport','IntegratedECLSSBay','CommandsFromOps','CommandTelemetryIF'; ...
    'OperationsAndLogisticsDeck','ConsumablesToCare','ColonyCareSuite','ConsumablesFromOps','ConsumablesLogisticsIF'; ...
    'IntegratedECLSSBay','ConditionedEnvironmentToHabitat','MonolithicHabitatBus','ConditionedEnvironmentIn','EnvironmentalControlIF'; ...
    'IntegratedECLSSBay','LifeSupportTelemetryToSafety','SafetyAssuranceShell','LifeSupportTelemetryIn','SafetyManagementIF'; ...
    'ColonyCareSuite','WasteReturnToLifeSupport','IntegratedECLSSBay','WasteAndRecoveryIn','WasteRecoveryIF'; ...
    'ColonyCareSuite','HealthStatusToOps','OperationsAndLogisticsDeck','HealthStatusIn','HealthWelfareIF'; ...
    'ColonyCareSuite','HealthStatusToSafety','SafetyAssuranceShell','ColonyHealthIn','HealthWelfareIF'; ...
    'SafetyAssuranceShell','SafetyStateToLifeSupport','IntegratedECLSSBay','SafetyStateIn','SafetyManagementIF'; ...
    'SafetyAssuranceShell','SafetyStateToOps','OperationsAndLogisticsDeck','SafetyStateIn','SafetyManagementIF'});

variants(2).Label = "Distributed Habitat Cluster";
variants(2).ModelName = "CATSS_Physical_DistributedHabitatCluster";
variants(2).File = "CATSS_Physical_DistributedHabitatCluster.slx";
variants(2).ShortName = "Distributed";
variants(2).AllocationFile = "CATSS_Functional_to_DistributedHabitatCluster.mldatx";
variants(2).CoreConcept = "Several smaller habitat modules cluster around a shared utility node and dedicated service elements for growth-driven expansion.";
variants(2).Strengths = "Best incremental growth path, strong social separation options, natural compartmentalization for quarantine and damage isolation.";
variants(2).Risks = "Highest interface and maintenance complexity, repeated shell overhead, more demanding inter-module logistics.";
variants(2).PressurePoints = "SR-019, SR-029, SR-030, SR-041, SR-042";
variants(2).RecommendationNote = "Best candidate when future colony growth and welfare zoning dominate, despite recurring logistics and interface penalties.";
variants(2).Properties = struct( ...
    "MassEstimate", 4.3, ...
    "VolumeEstimate", 5.0, ...
    "PowerEstimate", 4.7, ...
    "RecurringOpsComplexity", 4.4, ...
    "ModularityScore", 5.0, ...
    "ResupplyBurden", 4.1, ...
    "WelfareSupportScore", 4.8, ...
    "SafetyRobustnessScore", 4.1, ...
    "AutonomyEnablementScore", 3.6, ...
    "CostRisk", 4.4, ...
    "AffordabilityScore", 2.6, ...
    "ModularGrowthEfficiencyScore", 4.9, ...
    "ResupplySustainabilityScore", 2.7, ...
    "WelfareTradeScore", 4.8, ...
    "SafetyTradeScore", 4.2, ...
    "AutonomyTradeScore", 3.5);
variants(2).ScoreRationale = struct( ...
    "Affordability", "SR-039 and SR-040 suffer from repeated pressure shells, berthing hardware, and node-to-node utilities.", ...
    "ModularGrowthEfficiency", "SR-038 and SR-041 are strongest because habitat capacity can be added as independent pods around the cluster.", ...
    "ResupplySustainability", "SR-019, SR-029, and SR-042 are harder because consumables and waste handling must be balanced across more modules.", ...
    "WelfareSupport", "SR-010, SR-011, SR-014, and SR-015 benefit from natural separation of social groups into discrete habitats.", ...
    "SafetySurvivability", "SR-033 and SR-035 improve through compartment isolation, though SR-037 must serve more distributed loads.", ...
    "AutonomySupport", "OperateStation and CareForColony require broader network coordination to meet SR-030 and SR-031.");
variants(2).Components = buildComponentData( ...
    ["HabitatCluster","UtilityCoreNode","StationOpsAndBerthingNode","SafetyShelterNode","ColonyCareNode"], ...
    ["ProvideHabitat","SustainLifeSupport","OperateStation","EnsureSafety","CareForColony"], ...
    { ...
        {'HabitatPodAlpha','HabitatPodBeta','HabitatPodGamma','RefugeMeshHub'}, ...
        {'AtmosphereUtilityCore','WaterProcessingNode','ThermalBusNode','WasteRecoveryManifold'}, ...
        {'AutonomyComputeCluster','CommsRelay','ConsumablesWarehouse','ModularBerthingController'}, ...
        {'FaultIsolationBackbone','DistributedFireZones','EmergencyPowerTrunk','StormShelterPod'}, ...
        {'AutomatedFeedingBank','WasteCollectionHub','HealthMonitorNetwork','QuarantineSuite'}}, ...
    { ...
        {'SR-010','SR-011','SR-012','SR-013','SR-014','SR-015','SR-016','SR-017','SR-018'}, ...
        {'SR-001','SR-002','SR-003','SR-004','SR-005','SR-006','SR-007','SR-008','SR-009','SR-020','SR-024','SR-028','SR-029'}, ...
        {'SR-019','SR-028','SR-029','SR-030','SR-031','SR-032','SR-038','SR-039','SR-040','SR-041','SR-042'}, ...
        {'SR-033','SR-034','SR-035','SR-036','SR-037'}, ...
        {'SR-019','SR-021','SR-022','SR-023','SR-025','SR-026','SR-027','SR-030'}});
variants(2).Allocations = { ...
    'SustainLifeSupport','UtilityCoreNode'; ...
    'ProvideHabitat','HabitatCluster'; ...
    'OperateStation','StationOpsAndBerthingNode'; ...
    'EnsureSafety','SafetyShelterNode'; ...
    'CareForColony','ColonyCareNode'; ...
    'EnableModularGrowth','HabitatCluster'};
variants(2).Connections = buildConnections( ...
    { ...
    'StationOpsAndBerthingNode','CommandsToHabitatCluster','HabitatCluster','CommandsFromOps','CommandTelemetryIF'; ...
    'StationOpsAndBerthingNode','CommandsToUtilityCore','UtilityCoreNode','CommandsFromOps','CommandTelemetryIF'; ...
    'StationOpsAndBerthingNode','ConsumablesToCare','ColonyCareNode','ConsumablesFromOps','ConsumablesLogisticsIF'; ...
    'UtilityCoreNode','ConditionedEnvironmentToHabitatCluster','HabitatCluster','ConditionedEnvironmentIn','EnvironmentalControlIF'; ...
    'UtilityCoreNode','LifeSupportTelemetryToSafety','SafetyShelterNode','LifeSupportTelemetryIn','SafetyManagementIF'; ...
    'ColonyCareNode','WasteReturnToUtilityCore','UtilityCoreNode','WasteAndRecoveryIn','WasteRecoveryIF'; ...
    'ColonyCareNode','HealthStatusToOps','StationOpsAndBerthingNode','HealthStatusIn','HealthWelfareIF'; ...
    'ColonyCareNode','HealthStatusToSafety','SafetyShelterNode','ColonyHealthIn','HealthWelfareIF'; ...
    'SafetyShelterNode','SafetyStateToUtilityCore','UtilityCoreNode','SafetyStateIn','SafetyManagementIF'; ...
    'SafetyShelterNode','SafetyStateToOps','StationOpsAndBerthingNode','SafetyStateIn','SafetyManagementIF'});

variants(3).Label = "Service-Core With Replaceable Habitat Pods";
variants(3).ModelName = "CATSS_Physical_ServiceCorePods";
variants(3).File = "CATSS_Physical_ServiceCorePods.slx";
variants(3).ShortName = "ServiceCorePods";
variants(3).AllocationFile = "CATSS_Functional_to_ServiceCorePods.mldatx";
variants(3).CoreConcept = "A central infrastructure spine carries power, comms, life support, and docking while habitat pods are replaceable or incrementally added.";
variants(3).Strengths = "Best balance of reuse, scalable growth, and controlled interface standardization without full distributed overhead.";
variants(3).Risks = "Service core remains a concentration point, pod interfaces must be tightly standardized, and habitat replacement logistics stay nontrivial.";
variants(3).PressurePoints = "SR-033, SR-038, SR-039, SR-041";
variants(3).RecommendationNote = "Best overall under cost-plus-scalability weighting because it preserves pod growth while reusing the expensive utility core.";
variants(3).Properties = struct( ...
    "MassEstimate", 3.8, ...
    "VolumeEstimate", 4.1, ...
    "PowerEstimate", 4.0, ...
    "RecurringOpsComplexity", 3.0, ...
    "ModularityScore", 4.6, ...
    "ResupplyBurden", 2.8, ...
    "WelfareSupportScore", 4.1, ...
    "SafetyRobustnessScore", 4.1, ...
    "AutonomyEnablementScore", 4.0, ...
    "CostRisk", 3.0, ...
    "AffordabilityScore", 4.1, ...
    "ModularGrowthEfficiencyScore", 4.7, ...
    "ResupplySustainabilityScore", 4.0, ...
    "WelfareTradeScore", 4.0, ...
    "SafetyTradeScore", 4.1, ...
    "AutonomyTradeScore", 4.0);
variants(3).ScoreRationale = struct( ...
    "Affordability", "SR-039 and SR-040 improve because the service core is reused while smaller pods stay inside launch envelope targets.", ...
    "ModularGrowthEfficiency", "SR-038 and SR-041 are strong because pods attach through a standardized service spine without redesigning the core.", ...
    "ResupplySustainability", "SR-006, SR-019, SR-028, and SR-042 benefit from centralized utilities and staged pod resupply via one berthing node.", ...
    "WelfareSupport", "SR-010, SR-011, SR-014, and SR-015 are met with dedicated habitat pods, though contiguous free volume is lower than the monolith.", ...
    "SafetySurvivability", "SR-033, SR-035, and SR-037 remain solid with a dedicated safe-haven module and isolation-capable pod interfaces.", ...
    "AutonomySupport", "Direct allocation of life support and operations into the core spine supports SR-030 and SR-031 with simpler coordination than the cluster.");
variants(3).Components = buildComponentData( ...
    ["HabitatPodArray","ServiceCoreSpine","OperationsAndLogisticsHub","SafetyAndSafeHavenModule","ColonyCarePod"], ...
    ["ProvideHabitat","SustainLifeSupport","OperateStation","EnsureSafety","CareForColony"], ...
    { ...
        {'HabitatPodA','HabitatPodB','HabitatPodC','RefugeAndPerchInsert'}, ...
        {'CentralAtmosphereProcessor','WaterRecoveryTrunk','ThermalSpine','UtilityManifold'}, ...
        {'AvionicsSuite','CommsRelay','ResupplyPort','ConsumablesStaging'}, ...
        {'FaultManagementController','FireSuppressionLoop','EmergencyPowerBus','RadiationShelter'}, ...
        {'AutomatedFeedingWatering','WasteServiceAirlock','HealthTelemetryLab','VetIsolationBay'}}, ...
    { ...
        {'SR-010','SR-011','SR-012','SR-013','SR-014','SR-015','SR-016','SR-017','SR-018'}, ...
        {'SR-001','SR-002','SR-003','SR-004','SR-005','SR-006','SR-007','SR-008','SR-009','SR-020','SR-024','SR-028','SR-029'}, ...
        {'SR-019','SR-028','SR-029','SR-030','SR-031','SR-032','SR-038','SR-039','SR-040','SR-041','SR-042'}, ...
        {'SR-033','SR-034','SR-035','SR-036','SR-037'}, ...
        {'SR-019','SR-021','SR-022','SR-023','SR-025','SR-026','SR-027','SR-030'}});
variants(3).Allocations = { ...
    'SustainLifeSupport','ServiceCoreSpine'; ...
    'ProvideHabitat','HabitatPodArray'; ...
    'OperateStation','OperationsAndLogisticsHub'; ...
    'EnsureSafety','SafetyAndSafeHavenModule'; ...
    'CareForColony','ColonyCarePod'; ...
    'EnableModularGrowth','HabitatPodArray'};
variants(3).Connections = buildConnections( ...
    { ...
    'OperationsAndLogisticsHub','CommandsToPods','HabitatPodArray','CommandsFromOps','CommandTelemetryIF'; ...
    'OperationsAndLogisticsHub','CommandsToServiceCore','ServiceCoreSpine','CommandsFromOps','CommandTelemetryIF'; ...
    'OperationsAndLogisticsHub','ConsumablesToCare','ColonyCarePod','ConsumablesFromOps','ConsumablesLogisticsIF'; ...
    'ServiceCoreSpine','ConditionedEnvironmentToPods','HabitatPodArray','ConditionedEnvironmentIn','EnvironmentalControlIF'; ...
    'ServiceCoreSpine','LifeSupportTelemetryToSafety','SafetyAndSafeHavenModule','LifeSupportTelemetryIn','SafetyManagementIF'; ...
    'ColonyCarePod','WasteReturnToServiceCore','ServiceCoreSpine','WasteAndRecoveryIn','WasteRecoveryIF'; ...
    'ColonyCarePod','HealthStatusToOps','OperationsAndLogisticsHub','HealthStatusIn','HealthWelfareIF'; ...
    'ColonyCarePod','HealthStatusToSafety','SafetyAndSafeHavenModule','ColonyHealthIn','HealthWelfareIF'; ...
    'SafetyAndSafeHavenModule','SafetyStateToServiceCore','ServiceCoreSpine','SafetyStateIn','SafetyManagementIF'; ...
    'SafetyAndSafeHavenModule','SafetyStateToOps','OperationsAndLogisticsHub','SafetyStateIn','SafetyManagementIF'});
end

function components = buildComponentData(names, anchors, subcomponents, reqIds)
components = repmat(struct, 1, numel(names));
for idx = 1:numel(names)
    components(idx).Name = string(names(idx));
    components(idx).FunctionAnchor = string(anchors(idx));
    components(idx).Subcomponents = string(subcomponents{idx});
    components(idx).RequirementIds = string(reqIds{idx});
    components(idx).Bindings = defaultInternalBindings(components(idx).FunctionAnchor, components(idx).Subcomponents);
end
end

function connections = buildConnections(rows)
connections = repmat(struct, size(rows, 1), 1);
for idx = 1:size(rows, 1)
    connections(idx).SrcComp = string(rows{idx,1});
    connections(idx).SrcPort = string(rows{idx,2});
    connections(idx).DstComp = string(rows{idx,3});
    connections(idx).DstPort = string(rows{idx,4});
    connections(idx).Interface = string(rows{idx,5});
end
end

function createTradeProfile(profileName, profileFile, studyDir)
if isfile(profileFile)
    delete(profileFile);
end

profile = systemcomposer.profile.Profile.createProfile(profileName);
variantStereo = addStereotype(profile, "TradeVariant", AppliesTo="Component");
elementStereo = addStereotype(profile, "PhysicalElement", AppliesTo="Component");

numericProps = { ...
    'MassEstimate','VolumeEstimate','PowerEstimate','RecurringOpsComplexity', ...
    'ModularityScore','ResupplyBurden','WelfareSupportScore','SafetyRobustnessScore', ...
    'AutonomyEnablementScore','CostRisk','AffordabilityScore', ...
    'ModularGrowthEfficiencyScore','ResupplySustainabilityScore', ...
    'WelfareTradeScore','SafetyTradeScore','AutonomyTradeScore', ...
    'WeightedTotal','AlternateScenarioTotal', ...
    'AffordabilityWeight','ModularGrowthEfficiencyWeight','ResupplySustainabilityWeight', ...
    'WelfareSupportWeight','SafetySurvivabilityWeight','AutonomySupportWeight'};

for idx = 1:numel(numericProps)
    addProperty(variantStereo, numericProps{idx}, Type="double", DefaultValue="0");
end
addProperty(variantStereo, "Notes", Type="string", DefaultValue='""');
addProperty(variantStereo, "CoreConcept", Type="string", DefaultValue='""');
addProperty(variantStereo, "Strengths", Type="string", DefaultValue='""');
addProperty(variantStereo, "Risks", Type="string", DefaultValue='""');
addProperty(elementStereo, "FunctionAnchor", Type="string", DefaultValue='""');
addProperty(elementStereo, "ModuleRole", Type="string", DefaultValue='""');

profile.save(char(studyDir));
end

function createPhysicalInterfaceDictionary(dictFile)
if isfile(dictFile)
    delete(dictFile);
end

Simulink.data.dictionary.closeAll("-discard");
dict = systemcomposer.createDictionary(char(dictFile));

addInterfaceWithElements(dict, "CommandTelemetryIF", {'CommandCode','ModeState','TelemetryValue'});
addInterfaceWithElements(dict, "EnvironmentalControlIF", {'AtmosphereQuality','TemperatureMargin','WaterAvailability'});
addInterfaceWithElements(dict, "SafetyManagementIF", {'FaultState','EmergencyReserve','SafeModeCommand'});
addInterfaceWithElements(dict, "ConsumablesLogisticsIF", {'FoodMass','WaterMass','SpareMass'});
addInterfaceWithElements(dict, "WasteRecoveryIF", {'WasteLoad','RecoveryDemand','WaterYield'});
addInterfaceWithElements(dict, "HealthWelfareIF", {'HealthIndex','ActivityIndex','IsolationState'});
addInterfaceWithElements(dict, "DockingUtilityIF", {'DockStatus','UtilityTransfer','GrowthCapacity'});

dict.save();
end

function addInterfaceWithElements(dict, ifaceName, elementNames)
iface = addInterface(dict, ifaceName);
for idx = 1:numel(elementNames)
    addElement(iface, elementNames{idx}, Type="double");
end
end

function buildVariantModel(variant, studyDir, dictFile, profileName, criteria)
modelPath = fullfile(studyDir, variant.File);
model = systemcomposer.createModel(char(modelPath));
arch = model.Architecture;
linkDictionary(model, char(dictFile));
applyProfile(model, char(profileName));

dict = systemcomposer.openDictionary(char(dictFile));
interfaceLookup = buildInterfaceLookup(variant);

componentMap = containers.Map('KeyType','char','ValueType','any');
metadataComp = addComponent(arch, 'TradeStudyMetadata');
applyStereotype(metadataComp, char(profileName + ".TradeVariant"));
setVariantProperties(metadataComp, profileName, variant, criteria);

for idx = 1:numel(variant.Components)
    comp = addComponent(arch, char(variant.Components(idx).Name));
    applyStereotype(comp, char(profileName + ".PhysicalElement"));
    setStringProperty(comp, char(profileName + ".PhysicalElement.FunctionAnchor"), variant.Components(idx).FunctionAnchor);
    setStringProperty(comp, char(profileName + ".PhysicalElement.ModuleRole"), variant.Components(idx).FunctionAnchor + " implementation");
    addSubcomponents(comp, variant.Components(idx).Subcomponents);
    componentMap(char(variant.Components(idx).Name)) = comp;
end

for idx = 1:numel(variant.Connections)
    conn = variant.Connections(idx);
    srcComp = componentMap(char(conn.SrcComp));
    dstComp = componentMap(char(conn.DstComp));
    ensureComponentPort(srcComp, conn.SrcPort, "out");
    ensureComponentPort(dstComp, conn.SrcPort, "in");
    connect(srcComp, dstComp, Rule="name");
end

for idx = 1:numel(variant.Components)
    comp = componentMap(char(variant.Components(idx).Name));
    wireInternalBindings(comp, variant.Components(idx), dict, interfaceLookup);
end

save(model);
layoutVariantModel(char(variant.ModelName), variant);
assignVariantInterfaces(char(variant.ModelName), variant, dict);
try
    set_param(char(variant.ModelName), "SimulationCommand", "update");
catch ME
    if ~contains(ME.message, "contains no components or all components are virtual")
        rethrow(ME);
    end
end
save(model);
end

function addSubcomponents(component, names)
for idx = 1:numel(names)
    addComponent(component.Architecture, char(names(idx)));
end
end

function port = ensureComponentPort(component, portName, direction)
port = component.getPort(char(portName));
if isempty(port)
    addPort(component.Architecture, char(portName), char(direction));
end
port = component.getPort(char(portName));
end

function lookup = buildInterfaceLookup(variant)
lookup = containers.Map('KeyType', 'char', 'ValueType', 'char');
for idx = 1:numel(variant.Connections)
    conn = variant.Connections(idx);
    lookup(sprintf('%s|%s', char(conn.SrcComp), char(conn.SrcPort))) = char(conn.Interface);
    lookup(sprintf('%s|%s', char(conn.DstComp), char(conn.SrcPort))) = char(conn.Interface);
end
end

function wireInternalBindings(component, componentData, dict, interfaceLookup)
for idx = 1:numel(componentData.Bindings)
    binding = componentData.Bindings(idx);
    parentPort = component.getPort(char(binding.ParentPort));
    if isempty(parentPort)
        continue;
    end

    child = component.Architecture.getComponent(char(binding.ChildName));
    childPort = ensureComponentPort(child, binding.ParentPort, binding.Direction);

    key = sprintf('%s|%s', char(componentData.Name), char(binding.ParentPort));
    if isKey(interfaceLookup, key)
        iface = dict.getInterface(interfaceLookup(key));
        childPort.setInterface(iface);
    end

    archPort = component.Architecture.getPort(char(binding.ParentPort));
    if strcmp(binding.Direction, "in")
        connect(archPort, childPort);
    else
        connect(childPort, archPort);
    end
end
end

function bindings = defaultInternalBindings(anchor, subcomponents)
bindings = repmat(struct('ParentPort', "", 'ChildName', "", 'Direction', ""), 0, 1);

switch char(anchor)
    case 'ProvideHabitat'
        bindings = [ ...
            makeBinding("CommandsToHabitat", subcomponents(1), "in")
            makeBinding("CommandsToHabitatCluster", subcomponents(1), "in")
            makeBinding("CommandsToPods", subcomponents(1), "in")
            makeBinding("ConditionedEnvironmentToHabitat", subcomponents(1), "in")
            makeBinding("ConditionedEnvironmentToHabitatCluster", subcomponents(1), "in")
            makeBinding("ConditionedEnvironmentToPods", subcomponents(1), "in")];
    case 'SustainLifeSupport'
        bindings = [ ...
            makeBinding("CommandsToLifeSupport", subcomponents(1), "in")
            makeBinding("CommandsToUtilityCore", subcomponents(1), "in")
            makeBinding("CommandsToServiceCore", subcomponents(1), "in")
            makeBinding("SafetyStateToLifeSupport", subcomponents(1), "in")
            makeBinding("SafetyStateToUtilityCore", subcomponents(1), "in")
            makeBinding("SafetyStateToServiceCore", subcomponents(1), "in")
            makeBinding("WasteReturnToLifeSupport", subcomponents(end), "in")
            makeBinding("WasteReturnToUtilityCore", subcomponents(end), "in")
            makeBinding("WasteReturnToServiceCore", subcomponents(end), "in")
            makeBinding("ConditionedEnvironmentToHabitat", subcomponents(1), "out")
            makeBinding("ConditionedEnvironmentToHabitatCluster", subcomponents(1), "out")
            makeBinding("ConditionedEnvironmentToPods", subcomponents(1), "out")
            makeBinding("LifeSupportTelemetryToSafety", subcomponents(2), "out")];
    case 'OperateStation'
        bindings = [ ...
            makeBinding("CommandsToHabitat", subcomponents(1), "out")
            makeBinding("CommandsToHabitatCluster", subcomponents(1), "out")
            makeBinding("CommandsToPods", subcomponents(1), "out")
            makeBinding("CommandsToLifeSupport", subcomponents(1), "out")
            makeBinding("CommandsToUtilityCore", subcomponents(1), "out")
            makeBinding("CommandsToServiceCore", subcomponents(1), "out")
            makeBinding("ConsumablesToCare", subcomponents(3), "out")
            makeBinding("HealthStatusToOps", subcomponents(1), "in")
            makeBinding("SafetyStateToOps", subcomponents(1), "in")];
    case 'EnsureSafety'
        bindings = [ ...
            makeBinding("HealthStatusToSafety", subcomponents(1), "in")
            makeBinding("LifeSupportTelemetryToSafety", subcomponents(1), "in")
            makeBinding("SafetyStateToLifeSupport", subcomponents(1), "out")
            makeBinding("SafetyStateToUtilityCore", subcomponents(1), "out")
            makeBinding("SafetyStateToServiceCore", subcomponents(1), "out")
            makeBinding("SafetyStateToOps", subcomponents(1), "out")];
    case 'CareForColony'
        bindings = [ ...
            makeBinding("ConsumablesToCare", subcomponents(1), "in")
            makeBinding("HealthStatusToOps", subcomponents(3), "out")
            makeBinding("HealthStatusToSafety", subcomponents(3), "out")
            makeBinding("WasteReturnToLifeSupport", subcomponents(2), "out")
            makeBinding("WasteReturnToUtilityCore", subcomponents(2), "out")
            makeBinding("WasteReturnToServiceCore", subcomponents(2), "out")];
end
end

function binding = makeBinding(parentPort, childName, direction)
binding = struct('ParentPort', string(parentPort), 'ChildName', string(childName), 'Direction', string(direction));
end

function layoutVariantModel(modelName, variant)
load_system(modelName);

rootPositions = {
    [80 120 250 220]
    [360 40 530 140]
    [640 40 810 140]
    [640 240 810 340]
    [360 240 530 340]
    };

for idx = 1:numel(variant.Components)
    set_param([modelName '/' char(variant.Components(idx).Name)], 'Position', rootPositions{idx});
    layoutChildComponents(modelName, variant.Components(idx));
end

if bdIsLoaded(modelName) && ~isempty(find_system(modelName, 'SearchDepth', 1, 'Name', 'TradeStudyMetadata'))
    set_param([modelName '/TradeStudyMetadata'], 'Position', [900 40 1070 120]);
end
save_system(modelName);
end

function layoutChildComponents(modelName, componentData)
childPositions = {
    [50 40 160 100]
    [220 40 330 100]
    [50 150 160 210]
    [220 150 330 210]
    [135 260 245 320]
    };

parentPath = [modelName '/' char(componentData.Name)];
for idx = 1:numel(componentData.Subcomponents)
    set_param([parentPath '/' char(componentData.Subcomponents(idx))], 'Position', childPositions{idx});
end
end

function assignVariantInterfaces(modelName, variant, dict)
m = systemcomposer.openModel(modelName);
arch = m.Architecture;
for idx = 1:numel(variant.Connections)
    conn = variant.Connections(idx);
    iface = dict.getInterface(char(conn.Interface));
    srcComp = arch.getComponent(char(conn.SrcComp));
    dstComp = arch.getComponent(char(conn.DstComp));
    srcPort = srcComp.getPort(char(conn.SrcPort));
    dstPort = dstComp.getPort(char(conn.SrcPort));
    srcPort.setInterface(iface);
    dstPort.setInterface(iface);
end
save(m);
end


function setVariantProperties(arch, profileName, variant, criteria)
propPrefix = profileName + ".TradeVariant.";
fn = fieldnames(variant.Properties);
for idx = 1:numel(fn)
    setProperty(arch, char(propPrefix + fn{idx}), num2str(variant.Properties.(fn{idx}), '%.3f'));
end

primaryTotal = weightedTotal(variant.Properties, criteria.primaryWeights);
alternateTotal = weightedTotal(variant.Properties, criteria.alternateWeights);

setProperty(arch, char(propPrefix + "WeightedTotal"), num2str(primaryTotal, '%.3f'));
setProperty(arch, char(propPrefix + "AlternateScenarioTotal"), num2str(alternateTotal, '%.3f'));
setProperty(arch, char(propPrefix + "AffordabilityWeight"), num2str(criteria.primaryWeights.Affordability, '%.3f'));
setProperty(arch, char(propPrefix + "ModularGrowthEfficiencyWeight"), num2str(criteria.primaryWeights.ModularGrowthEfficiency, '%.3f'));
setProperty(arch, char(propPrefix + "ResupplySustainabilityWeight"), num2str(criteria.primaryWeights.ResupplySustainability, '%.3f'));
setProperty(arch, char(propPrefix + "WelfareSupportWeight"), num2str(criteria.primaryWeights.WelfareSupport, '%.3f'));
setProperty(arch, char(propPrefix + "SafetySurvivabilityWeight"), num2str(criteria.primaryWeights.SafetySurvivability, '%.3f'));
setProperty(arch, char(propPrefix + "AutonomySupportWeight"), num2str(criteria.primaryWeights.AutonomySupport, '%.3f'));

setStringProperty(arch, char(propPrefix + "Notes"), variant.RecommendationNote);
setStringProperty(arch, char(propPrefix + "CoreConcept"), variant.CoreConcept);
setStringProperty(arch, char(propPrefix + "Strengths"), variant.Strengths);
setStringProperty(arch, char(propPrefix + "Risks"), variant.Risks);
end

function total = weightedTotal(props, weights)
total = ...
    props.AffordabilityScore * weights.Affordability + ...
    props.ModularGrowthEfficiencyScore * weights.ModularGrowthEfficiency + ...
    props.ResupplySustainabilityScore * weights.ResupplySustainability + ...
    props.WelfareTradeScore * weights.WelfareSupport + ...
    props.SafetyTradeScore * weights.SafetySurvivability + ...
    props.AutonomyTradeScore * weights.AutonomySupport;
end

function createVariantAllocation(variant, allocDir, funcModelName, funcArch)
systemcomposer.allocation.AllocationSet.closeAll();
physModel = systemcomposer.openModel(char(variant.File));
physArch = physModel.Architecture;
allocName = erase(char(variant.AllocationFile), '.mldatx');
allocSet = systemcomposer.allocation.createAllocationSet(allocName, char(funcModelName), char(variant.ModelName));
scenario = allocSet.Scenarios(1);
scenario.Name = "FunctionalToPhysical";

for idx = 1:size(variant.Allocations, 1)
    srcComp = funcArch.getComponent(variant.Allocations{idx,1});
    dstComp = physArch.getComponent(variant.Allocations{idx,2});
    allocate(scenario, srcComp, dstComp);
end

save(allocSet, char(allocDir));
end

function createRequirementLinks(variant, reqFile, srSet)
physModel = systemcomposer.openModel(char(variant.File));
physArch = physModel.Architecture;

for idx = 1:numel(variant.Components)
    comp = physArch.getComponent(char(variant.Components(idx).Name));
    reqIds = variant.Components(idx).RequirementIds;
    for ridx = 1:numel(reqIds)
        req = srSet.find('Id', char(reqIds(ridx)));
        link = slreq.createLink(comp, req); %#ok<NASGU>
        link.Type = 'Implement';
    end
end

slreq.saveAll();
if isfile(reqFile) %#ok<NASGU>
    save(physModel);
end
end

function setStringProperty(obj, path, value)
escaped = strrep(char(value), '"', '''');
setProperty(obj, path, ['"' escaped '"']);
end

function writeTradeStudyReport(reportFile, variants, criteria)
primaryScores = zeros(1, numel(variants));
alternateScores = zeros(1, numel(variants));
for idx = 1:numel(variants)
    primaryScores(idx) = weightedTotal(variants(idx).Properties, criteria.primaryWeights);
    alternateScores(idx) = weightedTotal(variants(idx).Properties, criteria.alternateWeights);
end

[~, primaryOrder] = sort(primaryScores, "descend");
[~, altOrder] = sort(alternateScores, "descend");

fid = fopen(reportFile, "w");
assert(fid > 0, "Unable to open report file for writing.");
cleaner = onCleanup(@() fclose(fid));

fprintf(fid, "# CATSS Physical Architecture Trade Study\n\n");
fprintf(fid, "This report is generated by `architecture/physical_trade_study/build_catss_physical_trade_study.m`.\n\n");

fprintf(fid, "## Study Basis\n\n");
fprintf(fid, "- Source functional model: `architecture/CATSS_Functional.slx`\n");
fprintf(fid, "- Shared interface dictionary: `architecture/physical_trade_study/CATSS_PhysicalInterfaces.sldd`\n");
fprintf(fid, "- Shared trade profile: `architecture/physical_trade_study/CATSS_PhysicalTradeProfile.xml`\n");
fprintf(fid, "- Scoring uses relative engineering estimates for mass, volume, and power.\n\n");

fprintf(fid, "## Scoring Rules\n\n");
for idx = 1:numel(criteria.rules)
    fprintf(fid, "- %s\n", criteria.rules(idx));
end
fprintf(fid, "\n");

fprintf(fid, "## Primary Weights\n\n");
fprintf(fid, "| Criterion | Weight |\n");
fprintf(fid, "|---|---:|\n");
fprintf(fid, "| Development and recurring affordability | %.2f |\n", criteria.primaryWeights.Affordability);
fprintf(fid, "| Modular growth efficiency | %.2f |\n", criteria.primaryWeights.ModularGrowthEfficiency);
fprintf(fid, "| Resupply sustainability | %.2f |\n", criteria.primaryWeights.ResupplySustainability);
fprintf(fid, "| Welfare support | %.2f |\n", criteria.primaryWeights.WelfareSupport);
fprintf(fid, "| Safety and survivability | %.2f |\n", criteria.primaryWeights.SafetySurvivability);
fprintf(fid, "| Autonomy support | %.2f |\n\n", criteria.primaryWeights.AutonomySupport);

fprintf(fid, "## Comparison View\n\n");
fprintf(fid, "| Variant | Major modules | Functional allocation coverage | High-priority requirement coverage | Afford. | Growth | Resupply | Welfare | Safety | Autonomy | Weighted total |\n");
fprintf(fid, "|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|\n");
for idx = 1:numel(variants)
    modules = strjoin(arrayfun(@(c) char(c.Name), variants(idx).Components, UniformOutput=false), ", ");
    allocs = strjoin(variantAllocationSummary(variants(idx)), ", ");
    coverage = "Life support/autonomy, safety, architecture/cost, and welfare drivers covered";
    p = variants(idx).Properties;
    fprintf(fid, "| %s | %s | %s | %s | %.1f | %.1f | %.1f | %.1f | %.1f | %.1f | %.2f |\n", ...
        variants(idx).Label, modules, allocs, coverage, ...
        p.AffordabilityScore, p.ModularGrowthEfficiencyScore, p.ResupplySustainabilityScore, ...
        p.WelfareTradeScore, p.SafetyTradeScore, p.AutonomyTradeScore, primaryScores(idx));
end
fprintf(fid, "\n");

fprintf(fid, "## Ranking\n\n");
for rank = 1:numel(primaryOrder)
    idx = primaryOrder(rank);
    fprintf(fid, "%d. %s - %.2f\n", rank, variants(idx).Label, primaryScores(idx));
end
fprintf(fid, "\nRecommended baseline: **%s**.\n\n", variants(primaryOrder(1)).Label);

fprintf(fid, "### Alternate Weighting Scenario\n\n");
fprintf(fid, "If welfare and safety are weighted above affordability and growth, the ranking becomes:\n\n");
for rank = 1:numel(altOrder)
    idx = altOrder(rank);
    fprintf(fid, "%d. %s - %.2f\n", rank, variants(idx).Label, alternateScores(idx));
end
fprintf(fid, "\nThis alternate scenario keeps a non-winning concept visible when priorities change: **%s** becomes preferable under welfare and safety dominant weighting.\n\n", variants(altOrder(1)).Label);

fprintf(fid, "## Variant Rationales\n\n");
for idx = 1:numel(variants)
    fprintf(fid, "### %s\n\n", variants(idx).Label);
    fprintf(fid, "- Core concept: %s\n", variants(idx).CoreConcept);
    fprintf(fid, "- Expected strengths: %s\n", variants(idx).Strengths);
    fprintf(fid, "- Main penalties and risks: %s\n", variants(idx).Risks);
    fprintf(fid, "- Likely requirement pressure points: %s\n", variants(idx).PressurePoints);
    fprintf(fid, "- Affordability evidence: %s\n", variants(idx).ScoreRationale.Affordability);
    fprintf(fid, "- Growth evidence: %s\n", variants(idx).ScoreRationale.ModularGrowthEfficiency);
    fprintf(fid, "- Resupply evidence: %s\n", variants(idx).ScoreRationale.ResupplySustainability);
    fprintf(fid, "- Welfare evidence: %s\n", variants(idx).ScoreRationale.WelfareSupport);
    fprintf(fid, "- Safety evidence: %s\n", variants(idx).ScoreRationale.SafetySurvivability);
    fprintf(fid, "- Autonomy evidence: %s\n\n", variants(idx).ScoreRationale.AutonomySupport);
end
end

function summary = variantAllocationSummary(variant)
summary = strings(1, size(variant.Allocations, 1));
for idx = 1:size(variant.Allocations, 1)
    summary(idx) = string(variant.Allocations{idx,1}) + " -> " + string(variant.Allocations{idx,2});
end
end
