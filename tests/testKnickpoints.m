classdef testKnickpoints < matlab.perftest.TestCase
    properties
        dem
        fd
        s
    end

    properties (ClassSetupParameter)
        dataset
    end

    properties (TestParameter)
        uselibtt = {false, true};
    end

    methods (TestParameterDefinition,Static)
        function dataset = findDatasets()
            % Find all the existing snapshot datasets
            [~,available_datasets,~] = fileparts([{},struct2table(dir("snapshots/data/*/dem.tif")).folder]);
            if ~isempty(available_datasets)
                dataset = available_datasets;
            else
                error("No snapshots found.");
            end
        end
    end

    methods (TestClassSetup)
        % Shared setup for the entire test class
        function read_data(testCase,dataset)
            data_file = fullfile("snapshots/data/",dataset,"dem.tif");
            testCase.dem = GRIDobj(data_file);
            testCase.fd = FLOWobj(testCase.dem);
            s = STREAMobj(testCase.fd);
            testCase.s = klargestconncomps(s, 1);
            
            % Seed the random number generator
            rng(5526579, 'twister');
        end
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods
        function lowerenv_convex(testCase, uselibtt)
            S = testCase.s;
            % Test that lowerenv returns a convex profile
            nrc = numel(S.x);
            z = imposemin(S, testCase.dem);
            kn = rand(nrc, 1) >= 0.99;
            testCase.startMeasuring();
            zs = lowerenv(S, z, kn, uselibtt=uselibtt);
            testCase.stopMeasuring();

            if isProjected(testCase.dem)
                d = distance(S, 'node_to_node');
                g = zeros(nrc, 1);
                g(S.ix) = (zs(S.ix) - zs(S.ixc)) ./ d(S.ix);
                c = (g(S.ix) - g(S.ixc) >= -1e-2) | kn(S.ixc);
                testCase.verifyTrue(all(c));
            end
        end

        function knickpointfinder_convex(testCase, uselibtt)
            S = testCase.s;
            nrc = numel(S.x);

            testCase.startMeasuring();
            [zp, kp] = knickpointfinder(S, testCase.dem, ...
                'split', false, 'tol', 20, 'plot', false, 'verbose', false, ...
                'uselibtt', uselibtt);
            testCase.stopMeasuring();

            if isProjected(testCase.dem)
                d = distance(S, 'node_to_node');
                g = zeros(nrc, 1);
                g(S.ix) = (zp(S.ix) - zp(S.ixc)) ./ d(S.ix);
                c = (g(S.ix) - g(S.ixc) >= -1e-2) | kp.nal(S.ixc);
                testCase.verifyTrue(all(c));
            end
        end
    end
end