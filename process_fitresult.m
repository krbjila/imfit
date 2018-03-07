function [Results] = process_fitresult(FitResults, FitFunc, bin)

switch FitFunc
    case 1
        Offset = FitResults(1);
        PkOD = FitResults(2);
        X0 = FitResults(5);
        Y0 = FitResults(3);
        Sx = FitResults(6)*bin;
        Sy = FitResults(4)*bin;
        Angle = FitResults(7);
        
        Results = [PkOD Sx Sy X0 Y0 Offset];
        
    case 2
        Offset = FitResults(1);
        PkOD1 = FitResults(2);
        Sx1 = FitResults(3)*bin;
        Sy1 = FitResults(4)*bin;
        PkOD2 = FitResults(5);
        Sx2 = FitResults(6)*bin;
        Sy2 = FitResults(7)*bin;
        X0 = FitResults(8);
        Y0 = FitResults(9);
        
        if Sx1+Sy1 < Sx2+Sy2
            Results = [PkOD1 Sx1 Sy1 PkOD2 Sx2 Sy2 X0 Y0 Offset];
        else
            Results = [PkOD2 Sx2 Sy2 PkOD1 Sx1 Sy1 X0 Y0 Offset];
        end
end