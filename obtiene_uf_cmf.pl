#!/usr/bin/perl

################################################
# Modulos Basicos
################################################
use Getopt::Long;
use Date::Calc qw(:all);
use Data::Dumper;
use strict;
use JSON::PP;
use LWP::UserAgent;

my $url_cmf = "http://api.cmfchile.cl/api-sbifv3/recursos_api/uf";
my $api_key = "afsadfs"; #Se debe solicitar a la cmf

my ( $fecha_uf, $valor_uf ) = fn_obtiene_uf_rest($url_cmf, $api_key);

print("\tValores obtenidos: [".$fecha_uf."][".$valor_uf."]");

sub fn_obtiene_uf_rest{
	
	my $url_      = $_[0];
	my $apy_key_  = $_[1];
	
	
	my ( $ret_trx, %ret_trx, $elemento, $resultado, $cuenta, $cuerpo );	
	my ( $fecha_, $valor_ );
	my $json = new JSON::PP;
	my $url = $url_."?apikey=".$apy_key_."&formato=json";
	
	print("ENDPOINT: ".$url) if($CFG{debug} eq '1');
	
	eval 
        {
                my $userAgent = LWP::UserAgent->new() or return( '63', 'LWP::UserAgent');                
                $userAgent->agent("Mozilla/4") or return( '63', 'agent');
                $userAgent->timeout(10) or return( '63', 'timeout');  
                
				
                my $request = HTTP::Request->new("GET" => $url ) or return( '63', 'HTTP::Request');
                $request->header('content-type' => 'application/json');                
                $request->content("{}");                
                
                my $response    = $userAgent->request($request) or return( '63', 'request');
                my $statusmes   = $response->content or return( '63', 'response->content');
                        
                #$json_response    =    $response->content;
                if($response->code != 200 && $response->code != 201) 
                {
                        $fecha_   = 'error';                        
                }
                else
                {
                    $cuerpo = $response->content;
					
					print("RESPUESTA RECIBIDA: ".$response->content) if($CFG{debug} eq '1');	 
					
					$ret_trx = $json->decode($cuerpo);
					
					foreach my $elem (sort keys %$ret_trx) 
					{
						
						$cuenta++;			    
						$elemento  = lc($elem);
						$resultado = $ret_trx->{$elem};
						
						for my $hashref (@{$resultado}) {
							$valor_ = $hashref->{Valor};
							$fecha_ = $hashref->{Fecha};
						}							
						#print("  [$elemento]: -> [$resultado] ");
												
					}
					
                }
		};
		
		 return ($fecha_, $valor_ );
	
}