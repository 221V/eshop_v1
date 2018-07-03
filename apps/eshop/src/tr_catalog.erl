-module(tr_catalog).
-compile([export_all, nowarn_export_all]).

%translations module for catalog (caterories)


% translations
%tr(<<"en">>, <<"lang">>) -> <<"English">>;
tr(<<"en">>, <<"auto">>) -> <<"Auto">>;



%tr(<<"ru">>, test, <<"lang">>) -> <<"Русский"/utf8>>;



%tr(<<"uk">>, <<"lang">>) -> <<"Українська"/utf8>>;
tr(<<"uk">>, <<"auto">>) -> <<"Авто"/utf8>>;


%tr(_, _) -> <<"">>.
tr(_, A) -> A.

